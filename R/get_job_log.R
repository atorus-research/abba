#' Get job log from Kubernetes for a single job
#'
#' @param job_id a string that uniquely identifies the job
#'
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
#'
#' @return A list of job logs. Each list entry will contain complete log for a job
#'
get_job_log <- function(job_ids){
  logs <- lapply(job_ids, get_job_log0)
  return(logs)
}
