#' Submit R program as a SLURM job
#'
#' @param program_path Full path to the R program file. Must be accessible from the SLURM node
#' @param log_path desirable parent folder for program's log file. Defaults to parent folder of R program.
#' @param r_version Version of R that will be used to run the program. Can be specified as a full path to Rscript executable, or as a label of R version that is displayed in the Workbench GUI.
#' @param user_tag custom string that will be added to the job name.
#' @param cpu_cores Amount of CPU cores that will be requested for the job.
#' @param memory Amount of RAM in megabytes that will be requested for the job.
#' @param username user whose permission level is used to execute the script. Defaults to user submitting the job.
#' @param working_dir working directory for the SLURM job. Defaults to parent directory of `program_path`.
#' @param job_timeout time limit for a job. Must be specified in a format of "days-hours:minutes:seconds" If exceeded, job will be cancelled.
#' @param ... additional arguments (currently unused)
#'
#' @return job ID
#' @export
#'
#' @examples \dontrun{
#' job_id <- abba_slurm_submit_job("/home/user/tfl/t1_dm.sas")
#'  }
abba_slurm_submit_job <- function(program_path,
                                  log_path=NULL,
                                  r_version=NULL,
                                  user_tag=NULL,
                                  cpu_cores=getOption("abba.slurm.cpu.cores"),
                                  memory=getOption("abba.slurm.memory"),
                                  username=NULL,
                                  working_dir=NULL,
                                  job_timeout=3600,
                                  ...) {

  # default to current session version of R if not provided by user
  rscript_path <- select_rscript_version(r_version)

  # Submit the job for the program and wait until its execution
  scriptPath <- path.expand(program_path)
  scriptFile <- basename(scriptPath)
  jobTag <- c(paste("rstudio-r-script-job", scriptPath, sep = ":"), user_tag)

  # put log file in r script folder if no log path is supplied
  log_path <- slurm_config_determine_log_path(log_path = log_path, program_path = program_path)

  # create log directory if it does not exist
  if (!file.exists(dirname(log_path))){dir.create(dirname(log_path))}

  # assign working directory to parent dir of submitted program
  if (is.null(working_dir)){working_dir <- dirname(program_path)}

  # Configure job to run our program
  job_config <- configure_slurm_job(program_path=program_path,
                                    log_path=log_path,
                                    rscript_path=rscript_path,
                                    user_tag=user_tag,
                                    cpu_cores=cpu_cores,
                                    memory=memory,
                                    username=username,
                                    job_timeout=job_timeout
  )

  # Save yaml to temp folders
  job_config_path <- save_slurm_template(job_config)

  # Send the job for execution and read job id
  job_id <- submit_slurm_job_config(job_config_path)

  # return path of the executed script along with execution status(anything other than 0 is a failure)
  return(job_id)

}


#' Function to get SLURM job log
#'
#' @param job_id string representing a valid SLURM job ID
#' @param ... other arguments that will be ignored
#'
#' @return character vector containing job log
#' @noRd
#'
get_slurm_job_log0 <- function(job_id, ...){

  # try and get log path for a given job
  log_path <- get_slurm_job_log_path(job_id, ...)

  if (!file.exists(log_path)){
    stop(sprintf('Cannot find log for job %s. File %s does not exist.', job_id, log_path))
  }

  return(readLines(con=log_path))
}


#' Return job log for each submitted job ID
#'
#' @param job_ids valid SLURM job IDs
#' @param ... other parameters that will be ignored
#'
#' @return list of character vectors. each character vector would represent program log.
#' @export
#'
#' @examples \dontrun{
#' job_log <- abba_slurm_get_job_log("156")}
#'
abba_slurm_get_job_log <- function(job_ids, ...){
  return(lapply(job_ids, get_slurm_job_log0))
}


# return TRUE if job exit code is 0, and FALSE otherwise
#' Get SLURM job exit code represented by a boolean variable
#'
#' @param job_id a valid SLURM job ID
#' @param ... other parameters that will be ignored
#'
#' @return TRUE if job finished running and has 'COMPLETED' status, FALSE otherwise.
#' If job has not finished running, a NULL will be returned.
#' @noRd
#'
abba_slurm_get_job_succeeded0 <- function(job_id, ...){
  output <- suppressWarnings(system2(command="squeue",
                                     args=c('--jobs', job_id, '--Format="UserName,Name:.60,JobID:.10,exit_code:.14,State:.20"', "--states=all"),
                                     stdout=TRUE, stderr=TRUE))

  system_command_error_check(output, sprintf("Error getting job exit code for job ID %s.", job_id))
  parsed_output <- slurm_parse_squeue_output(output)
  parsed_output <- parsed_output[parsed_output$JOBID == job_id, , drop = FALSE]
  if(parsed_output$STATE == 'COMPLETED') {job_succeeded <- TRUE}
  else if(parsed_output$STATE %in% c('CONFIGURING', 'COMPLETING', 'PENDING', 'RUNNING', 'SIGNALING', 'RESIZING')) {job_succeeded <- NULL}
  else {job_succeeded <- FALSE}
  return(job_succeeded)
}


#' Check whether SLURM jobs have been fully executed.
#'
#' @param job_ids a list/vector of  valid SLURM job IDs
#' @param ... other parameters that will be ignored
#'
#' @return a named boolean vector. TRUE if job finished running and has 'COMPLETED' status, FALSE otherwise.
#' If job has not finished running, a NULL will be returned.
#' @export
#'
#' @examples \dontrun{
#' job_statuses <- abba_slurm_get_job_succeeded(c('job-id-1', 'job-id-2'))
#' }
abba_slurm_get_job_succeeded <- function(job_ids, ...){
  results <- sapply(job_ids, abba_slurm_get_job_succeeded0)
  if (any(sapply(results, function(x) is.null(x)))){
    stop(sprintf(
      "Jobs %s are still executing. Try increasing timeout parameter to avoid this error.",
      paste(job_ids[is.null(results)], collapse='\n\t')))
  }
  return(results)
}


#' Return descriptive job status for SLURM job
#'
#' @param job_id a valid Slurm job ID
#' @param ... other positional/keyword arguments that will be ignored
#'
#' @return a named character vector with job status as value and job ID as name.
#' @noRd
slurm_get_job_status0 <- function(job_id, ...){
  output <- suppressWarnings(system2(command="squeue",
                                     args=c('--jobs', job_id, '--format="%.18i %.20P %.60j %.25u %.15T %.12M %.9l"', "--states=all"),
                                     stdout=TRUE, stderr=TRUE))

  system_command_error_check(output, sprintf("Error getting job status for job ID %s.", job_id))
  parsed_output <- slurm_parse_squeue_output(output)
  parsed_output <- parsed_output[parsed_output$JOBID %in% job_id, , drop = FALSE]

  return(parsed_output$STATE)
}


#' Return descriptive job status for slurm jobs
#'
#' @param job_ids a list/vector of Slurm job IDs
#' @param ... other positional/keyword arguments that will be ignored
#'
#' @return a named character vector with job statuses as values and job IDs as names.
#' @export
#'
#' @examples \dontrun{
#' job_statuses <- slurm_get_job_status(c('job-id-1', 'job-id-2'))
#' }
abba_slurm_get_job_status <- function(job_ids, ...){
  result <- sapply(job_ids, slurm_get_job_status0)
  return(result)
}


#' Watch SLURM job, periodically polling its execution status.
#'
#' @param job_id job ID that was specified when submitting jobs
#' @param poll_interval_seconds Time interval for polling job status in seconds
#' @param timeout_seconds Total time to wait before timeout in seconds
#' @param ... other positional/keyword arguments that will be ignored
#'
#' @return a list of job ID(s) and status(es)
#' @export
#'
#' @examples \dontrun{
#' result <- abba_slurm_watch_job("5195", 10, 3000)
#' }
#'
abba_slurm_watch_job <- function(job_id='',
                                 poll_interval_seconds = 3,
                                 timeout_seconds = 300,
                                 ...){
  # Initialize variables for tracking job status
  start_time <- Sys.time()

  # Poll for job status in the specified batch group
  while (difftime(Sys.time(), start_time, units = "secs") <= timeout_seconds) {

    job_details <- abba_slurm_get_job_status(job_id)

    job_still_running_statuses <- c("CONFIGURING", "RUNNING", "COMPLETING", "PENDING")
    # Check if all jobs finished running
    if (!any(sapply(job_details, function(x){x %in% job_still_running_statuses}))) {
      break # Break if no "Pending" or "Running" in the names of job_details
    }

    # Wait for the specified interval before polling again
    Sys.sleep(poll_interval_seconds)
  }

  return(job_details)
}
