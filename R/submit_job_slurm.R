#' Submit R program as a SLURM job
#'
#' @param program_path
#' @param log_path
#' @param r_version
#' @param user_tag
#' @param cpu_cores
#' @param memory
#' @param username
#' @param job_timeout
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
slurm_submit_job <- function(program_path,
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
  log_path <- slurm_config_determine_log_folder(log_path = log_path, program_path = program_path)

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

configure_slurm_job <- function(program_path='',
                                log_path='',
                                rscript_path='',
                                user_tag='',
                                cpu_cores=getOption("abba.slurm.cpu.cores"),
                                memory=getOption("abba.slurm.memory"),
                                username=NULL,
                                job_timeout=3600
                                ){

  slurm_config_obj <- load_slurm_template()

  program_name <- unlist(strsplit(basename(program_path), '.', fixed = TRUE))[1]

  # cannot have underscores in job name/generate name
  job_name <- gsub('_', '-', program_name)
  generate_name <- paste0(job_name, '-', uuid::UUIDgenerate())

  # Pull supplied username if provided, otherwise default to local user
  if (is.null(username)){
    service_user <- Sys.info()[["user"]]
  } else {
    service_user <- username
  }
  guid <- get_guid(user=service_user)

  # a function that would try to replace all possible keywords inside the target string
  replace_func <- function(x){
    x <- gsub("SLURM_JOB_UID", guid$uid, x)
    x <- gsub("SLURM_JOB_TIMEOUT", job_timeout, x)
    x <- gsub("CPU_CORES", cpu_cores, x)
    x <- gsub("RAM_MB", memory, x)
    x <- gsub("SLURM_JOB_JOB_NAME", generate_name, x)
    x <- gsub("PROGRAM_LOG_PATH", log_path, x)
    x <- gsub("RSCRIPT_PATH", rscript_path, x)
    x <- gsub("R_PROGRAM_PATH", program_path, x)
    x <- gsub("R_PROGRAM_FOLDER_PATH", dirname(program_path), x)
    return(x)
  }

  # recursively walk the yaml and replace all placeholders with actual values
  recursive_replace <- function(l){
    sapply(l, function(x) if(is.list(x)) recursive_replace(x)
           else if(is.character(x)) replace_func(x)
           else x, USE.NAMES = FALSE)
  }

  slurm_config_obj <- recursive_replace(slurm_config_obj)

  return(slurm_config_obj)

}

# function for submitting slurm config. Takes in a file path to config as the only argument
submit_slurm_job_config <- function(slurm_config_path){
  # send the job for execution
  output <- suppressWarnings(system2(command="sbatch",
                                     args=c(slurm_config_path),
                                     stdout=TRUE, stderr=TRUE))
  slurm_command_error_check(output, "Error submitting the job.")
  # read job id from config and return it for further tracking and reporting
  return(slurm_config_get_job_id(output))
}

# Function for parsing slurm config to extract job id
slurm_config_get_job_id <- function(output){
  job_id <- stringr::str_extract(output, stringr::regex("(?<=job )\\d+$"))
  return(job_id)
}

# Function to determine where to place program logs depending on supplied log path/program path
slurm_config_determine_log_folder <- function(log_path=NULL,
                                              program_path=NULL){
  if (is.null(program_path) || program_path == ''){
    stop(sprintf("Program_path parameter should be a real path, not %s", typeof(program_path)))
  }
  # put log file in r script folder if no log path is supplied
  if (is.null(log_path) || log_path == ''){
    log_path <- file.path(dirname(program_path), paste0(tools::file_path_sans_ext(basename(program_path)), '.log'))
  } else {log_path <- file.path(log_path, paste0(tools::file_path_sans_ext(basename(program_path)), '.log'))}

  return (log_path)
}

# function to get job log path
get_slurm_job_log_path <- function(job_id, ...){
  # get job info
  output <- suppressWarnings(system2(command="scontrol",
                                     args=c("show job", job_id),
                                     stdout=TRUE, stderr=TRUE))
  slurm_command_error_check(output, "Error getting job log path.")

  parsed_output <- slurm_parse_scontrol_output(output)

  return(parsed_output$StdOut)
}

# function to get slurm job log
get_slurm_job_log0 <- function(job_id, ...){

  # try and get log path for a given job
  log_path <- get_slurm_job_log_path(job_id, ...)

  if (!file.exists(log_path)){
    stop(sprintf('Cannot find log for job %s. File %s does not exist.', job_id, log_path))
  }

  return(readLines(con=log_path))
}

# vectorized version of get_slurm_job_log0
abba_slurm_get_job_log <- function(job_ids, ...){
  return(lapply(job_ids, get_slurm_job_log0))
}


# return TRUE if job exit code is 0, and FALSE otherwise
abba_slurm_get_job_succeeded0 <- function(job_id, ...){
  output <- suppressWarnings(system2(command="squeue",
                                     args=c('--jobs', job_id, '--Format="UserName,Name:.60,JobID:.10,exit_code:.14"', "--states=all"),
                                     stdout=TRUE, stderr=TRUE))

  slurm_command_error_check(output, sprintf("Error getting job exit code for job ID %s.", job_id))
  parsed_output <- slurm_parse_squeue_output(output) %>% dplyr::filter(JOBID %in% job_id)
  job_succeeded <- if(parsed_output$EXIT_CODE == 0) TRUE else FALSE
  return(job_succeeded)
}


#' Check whether Slurm jobs have been fully executed.
#'
#' @param job_ids a list/vector of Slurm job IDs
#' @param ... other positional/keyword arguments
#'
#' @return a named boolean vector. FALSE value indicates that job did not fully execute
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


#' Return job status for slurm job given job ID
slurm_get_job_status0 <- function(job_id, ...){
  output <- suppressWarnings(system2(command="squeue",
                                     args=c('--jobs', job_id, '--format="%.18i %.20P %.60j %.25u %.15T %.12M %.9l"', "--states=all"),
                                     stdout=TRUE, stderr=TRUE))

  slurm_command_error_check(output, sprintf("Error getting job status for job ID %s.", job_id))
  parsed_output <- slurm_parse_squeue_output(output) %>% dplyr::filter(JOBID %in% job_id)

  return(parsed_output$STATE)
}


#' Return descriptive job status for slurm jobs
#'
#' @param job_ids a list/vector of Slurm job IDs
#' @param ... other positional/keyword arguments that will be ignored
#'
#' @return a named character vector with job statuses as values and job IDs as names.
#' @noRd
#'
#' @examples \dontrun{
#' job_statuses <- slurm_get_job_status(c('job-id-1', 'job-id-2'))
#' }
slurm_get_job_status <- function(job_ids, ...){
  result <- sapply(job_ids, slurm_get_job_status0)
  return(result)
}
