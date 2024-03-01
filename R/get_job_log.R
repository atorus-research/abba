#' Get job log from Kubernetes for a single job
#'
#' @param job_id a string that uniquely identifies the job
#' @noRd
#' @export
#' @return A character vector containing job's log
#'
get_job_log0 <- function(job_id){

  # run the command for outputting job log
  # this command will generate warning in case job with a given ID does not exist
  # that's why there is a suppressWarnings in place
  log <- suppressWarnings(system2(command="kubectl",
                 args=c("logs", "-n" ,"rstudio", paste0("jobs/", job_id)),
                 stdout=TRUE, stderr=TRUE))

  # return custom error message about invalid job ID if job was not found
  if(!is.null(attributes(log))){
    if("status" %in% names(attributes(log)) & attr(log, "status")==1){
      return(paste0("Job ", job_id, " not found."))
      }
    }
  return(as.character(log))
}

#' Get log for every job specified in an input vector/list
#'
#' @param job_ids A list of job IDs to get logs for
#' @noRd
#' @export
#' @return A list of job logs. Each list entry will contain complete log for a job
#'
get_job_log <- function(job_ids){
  logs <- lapply(job_ids, get_job_log0)
  return(logs)
}

#' Return list of logs for jobs that are marked with a given batch ID
#'
#' @param batch_id string containing batch ID
#' @noRd
#' @export
#' @return Job logs in a from of list consisting of character vectors
#'
get_batch_log <- function(batch_id){

  # get all job IDs belonging to a given batch
  job_ids <- get_batch_ids(batch_id)

  logs <- lapply(job_ids, get_job_log0)

  return(logs)
}
