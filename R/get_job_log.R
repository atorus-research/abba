#' Get job log from Kubernetes for a single job
#'
#' @param job_id a string that uniquely identifies the job
#' @param namespace Kubernetes namespace to search for job
#'
#' @noRd
#' @return A list containing job_id and a character vector with jobs log
#'
get_k8s_job_log0 <- function(job_id,
                             namespace=getOption('abba.k8s.namespace')){

  # run the command for outputting job log
  # this command will generate warning in case job with a given ID does not exist
  # that's why there is a suppressWarnings in place
  log <- suppressWarnings(system2(command="kubectl",
                 args=c("logs", "-n" , namespace, paste0("jobs/", job_id)),
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
#' @param namespace Kubernetes namespace to search for pod
#'
#' @noRd
#' @return A character vector containing pod log.
#'
get_k8s_pod_log0 <- function(pod_id,
                             namespace=getOption('abba.k8s.namespace')){
  # run the command for outputting job log
  # this command will generate warning in case job with a given ID does not exist
  # that's why there is a suppressWarnings in place
  log <- suppressWarnings(system2(command="kubectl",
                                  args=c("logs", "-n" , namespace, pod_id),
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
#' @param namespace Kubernetes namespace to search for job
#'
#' @export
#' @return A list of job logs. Each list entry will contain complete log for a job
#'
abba_get_k8s_job_log_local <- function(job_ids,
                                       namespace=getOption('abba.k8s.namespace')){
  logs <- lapply(job_ids, function(x) get_k8s_job_log0(x, namespace=namespace))
  return(logs)
}


#' Return list of logs for jobs that are marked with a given batch ID
#'
#' @param batch_id string containing batch ID
#' @param namespace Kubernetes namespace to search for batch jobs
#'
#' @export
#' @return Job logs in a from of list consisting of character vectors
#'
abba_get_k8s_batch_log_local <- function(batch_id,
                                         namespace=getOption('abba.k8s.namespace')){

  # get all pod IDs belonging to a given batch
  pod_ids <- get_k8s_job_ids_from_batch(batch_id, namespace=namespace)

  logs <- lapply(pod_ids, function(x) get_k8s_pod_log0(x, namespace=namespace))

  return(logs)
}
