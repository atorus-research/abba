#' Get job log from Kubernetes for a single job
#'
#' @param job_id a string that uniquely identifies the job
#'
#' @noRd
#' @return A list containing job_id and a character vector with jobs log
#'
abba_get_k8s_job_log0_local <- function(job_id){

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
  return(list(job_id=job_id, log=as.character(log)))
}


#' Get log for a pod
#'
#' @param pod_id Pod ID to get logs for
#'
#' @noRd
#' @return A character vector containing pod log.
#'
abba_get_k8s_pod_log0_local <- function(pod_id){
  # run the command for outputting job log
  # this command will generate warning in case job with a given ID does not exist
  # that's why there is a suppressWarnings in place
  log <- suppressWarnings(system2(command="kubectl",
                                  args=c("logs", "-n" ,"rstudio", pod_id),
                                  stdout=TRUE, stderr=TRUE))

  # return custom error message about invalid job ID if job was not found
  if(!is.null(attributes(log))){
    if("status" %in% names(attributes(log)) & attr(log, "status")==1){
      return(paste0("Pod ", pod_id, " not found."))
    }
  }
  return(list(pod_id=pod_id, log=as.character(log)))
}


#' Get log for every job specified in an input vector/list
#'
#' @param job_ids A list of job IDs to get logs for
#'
#' @export
#' @return A list of job logs. Each list entry will contain complete log for a job
#'
abba_get_k8s_job_log_local <- function(job_ids){
  logs <- lapply(job_ids, abba_get_k8s_job_log0_local)
  return(logs)
}


#' Return list of logs for jobs that are marked with a given batch ID
#'
#' @param batch_id string containing batch ID
#'
#' @export
#' @return Job logs in a from of list consisting of character vectors
#'
abba_get_k8s_batch_log_local <- function(batch_id){

  # get all pod IDs belonging to a given batch
  pod_ids <- abba_get_k8s_job_ids_from_batch_local(batch_id)

  logs <- lapply(pod_ids, abba_get_k8s_pod_log0_local)

  return(logs)
}
