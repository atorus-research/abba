rslauncher_submit_job <- function(p,
                                  execution_type='standard',
                                  log_path=NULL,
                                  user_tag=NULL,
                                  ...) {

  # check execution type
  if (!(execution_type %in% c('standard', 'logrx'))){
    stop(sprintf("execution_type argument must be 'standard' or 'logrx', not %s", execution_type))
  }
  # Submit the job for the program and wait until its execution
  scriptPath <- path.expand(p)
  scriptFile <- basename(scriptPath)
  jobTag <- c(paste("rstudio-r-script-job", scriptFile, sep = ":"), user_tag)

  # put log file in r script folder if no log path is supplied
  if (is.null(log_path) || log_path == ''){
    log_path=file.path(dirname(scriptPath), paste0(tools::file_path_sans_ext(basename(scriptPath)), '.log'))
  } else {log_path=file.path(log_path, paste0(tools::file_path_sans_ext(basename(scriptPath)), '.log'))}

  # define scriptpath depending on the execution type
  if (execution_type == 'standard'){
    scriptArg <- paste("-f", scriptPath)
  }
  else if (execution_type == 'logrx'){
    scriptArg <- sprintf("-f %s --args %s %s",
                         system.file('logrx_workbench_submission.R', package="abba"),
                         scriptPath,
                         log_path)
  }
  # submit program for execution via rstudioapi
  job_id <- rstudioapi::launcherSubmitJob(args =  c("--slave", "--no-save", "--no-restore", scriptArg),
                                          cluster = 'Local',
                                          command = "R",
                                          stdoutFile = log_path,
                                          stderrFile = log_path,
                                          name = scriptPath,
                                          tags = c(jobTag)
  )
  # return path of the executed script along with execution status(anything other than 0 is a failure)
  return(job_id)

}


abba_rslauncher_submit_job_local <- function(p,
                                             log_path=NULL,
                                             user_tag='',
                                             ...) {

  job_id <- rslauncher_submit_job(p,
                                  execution_type='standard',
                                  log_path=log_path,
                                  user_tag=user_tag,
                                  ...)

  # return path of the executed script along with execution status(anything other than 0 is a failure)
  return(job_id)

}


abba_rslauncher_submit_logrx_job_local <- function(p,
                                                   log_path=NULL,
                                                   user_tag='',
                                                   ...) {

  rslauncher_submit_job(p,
                        execution_type='logrx',
                        log_path=log_path,
                        user_tag=user_tag,
                        ...)

}


# simple function to get the job status
#' Get Workbench job status for a given vector/list of job IDs
#'
#' @param job_ids A list/vector of job IDs
#' @param ... other positional/keyword arguments that will be ignored
#'
#' @return a vector of job ID statuses
#' @export
#'
#' @examples \dontrun{
#' job_statuses <- abba_rslauncher_get_job_status_local(c('job-id-1', 'job-id-2'))
#' }
abba_rslauncher_get_job_status_local <- function(job_ids,
                                                 ...){
  return(sapply(job_ids, function(x) rstudioapi::launcherGetJob(x)[['status']]))
}


#' Periodically poll Workbench jobs for status and return their IDs when all job
#' statuses arrive at 'Finished' state
#'
#' @param job_ids a list/vector of Workbench job IDs
#' @param poll_interval_seconds how often job statuses should be updated
#' @param timeout_seconds maximum amount of time in seconds after which job IDs will be
#' returned regardless of job statuses
#' @param ... other positional/keyword arguments that will be ignored
#'
#' @return a vector of job IDs
#' @export
#'
#' @examples \dontrun{
#' job_statuses <- abba_rslauncher_watch_job_local(c('job-id-1', 'job-id-2'))
#' }
abba_rslauncher_watch_job_local <- function(job_ids,
                                            poll_interval_seconds = 1,
                                            timeout_seconds = 300,
                                            ...){
  # Initialize variables for tracking job status
  start_time <- Sys.time()

  # Watch the job while it's executing
  while (difftime(Sys.time(), start_time, units = "secs") <= timeout_seconds) {

    statuses <- abba_rslauncher_get_job_status_local(job_ids)
    # Check if job has finished running
    if (all(statuses == "Finished")) {
      break # Break if job has reached 'Finished' status
    }
    # Wait for the specified interval before polling again
    Sys.sleep(poll_interval_seconds)
  }
  if (difftime(Sys.time(), start_time, units = "secs") > timeout_seconds) {
    warning(sprintf("Timeout limit exceeded for jobs:\n\t%s. \nJob IDs have been returned while jobs are still running.",
                    paste(job_ids[!(statuses == "Finished")], collapse='\n\t')))
  }
  return(job_ids)
}


# simple function to get job log
get_rslauncher_job_log0 <- function(job_id, ...){

  # default rstudio api error when non-existing job id is supplied is gibberish,
  # so it's better to display a simple error message to the user
  tryCatch({job_info <- rstudioapi::launcherGetJob(job_id)},
           error=function(e){stop(sprintf("Job with ID '%s' does not exist.", job_id))}
  )

  if (!file.exists(job_info$stdoutFile)){
    return(c(sprintf('Log file does not exist for %s', job_info$id)))
  }

  return(readLines(con=job_info$stdoutFile))
}


# vectorized version of get_workbench_job_log0
abba_rslauncher_get_job_log_local <- function(job_ids, ...){
  return(lapply(job_ids, get_rslauncher_job_log0))
}


# simple function to check whether job finished running without errors
# will return TRUE if exitCode is equal to 0, i.e. no errors occured during execution.
# does not check for warnings, only hard R errors
rslauncher_get_job_succeeded0 <- function(job_id, ...){
  job_info <- rstudioapi::launcherGetJob(job_id)

  if (is.null(job_info$exitCode)){return(NULL)}
  return(job_info$exitCode == 0)
}


#' Check whether Workbench jobs have been fully executed.
#'
#' @param job_ids a list/vector of Workbench job IDs
#' @param ... other positional/keyword arguments that will be ignored
#'
#' @return a named boolean vector. FALSE value indicates that job did not fully execute
#' @export
#'
#' @examples \dontrun{
#' job_statuses <- abba_rslauncher_get_job_succeeded_local(c('job-id-1', 'job-id-2'))
#' }
abba_rslauncher_get_job_succeeded_local <- function(job_ids, ...){
  results <- sapply(job_ids, rslauncher_get_job_succeeded0)
  if (any(sapply(results, function(x) is.null(x)))){
    stop(sprintf(
      "Jobs %s are still executing. Try increasing timeout parameter to avoid this error.",
      paste(job_ids[is.null(results)], collapse='\n\t')))
  }
  return(results)
}


#' Return descriptive job status based on program exitCode
#'
#' @param job_ids a list/vector of Workbench job IDs
#' @param ... other positional/keyword arguments that will be ignored
#'
#' @return a named character vector. Possible statuses are 'Completed', 'Completed with errors'
#' @noRd
#'
#' @examples \dontrun{
#' job_statuses <- abba_rslauncher_get_job_display_status(c('job-id-1', 'job-id-2'))
#' }
rslauncher_get_job_display_status <- function(job_ids, ...){
  intermediate_results <- sapply(job_ids, rslauncher_get_job_succeeded0)
  if (any(sapply(intermediate_results, function(x) is.null(x)))){
    stop(sprintf(
      "Jobs %s are still executing. Try increasing timeout parameter to avoid this error.",
      paste(job_ids[is.null(intermediate_results)], collapse='\n\t')))
  }

  # function to convert TRUE/FALSE results into descriptive character statuses
  make_descriptive <- function(x){
    if(x==TRUE){'Completed'}
    else if(x==FALSE){'Completed with errors'}
  }

  results <- sapply(intermediate_results, make_descriptive)

  return(results)
}
