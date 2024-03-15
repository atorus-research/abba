library(plumber)
library(abba)

options(
  abba.lower.cpu.limit=0.5,
  abba.cpu.limit = 2,
  abba.lower.memory.limit='128M',
  abba.memory.limit='1G',
  abba.permitted.containers = c("registry.io/default_image:version",
                                "registry.io/image1:version",
                                "registry.io/image1:version"),
  abba.default.container = "registry.io/default_image:version",
  abba.k8s.namespace='rstudio'
)

# Returns a list containing "user" and "groups" information
# populated by incoming request data.
getUserMetadata <- function(req) {
  rawUserData <- req[["HTTP_RSTUDIO_CONNECT_CREDENTIALS"]]
  if (!is.null(rawUserData)) {
    jsonlite::fromJSON(rawUserData)
  } else {
    list()
  }
}

#* @apiTitle {abba} API
#* @apiDescription Backend submission API for {abba}

#* Submit a job on Kubernetes
#' @param file_path Full path to R file
#' @param batch_group_id Group ID for batch processing
#' @param user_tag Optional; a string that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param container A string containing a permitted container name. Default is specified by API administrator.
#' @param mounts Specifically formatted list with information bout volumes that container would have access to during the run
#' @param namespace Kubernetes namespace to put the job in
#* @post /submit-job
function(file_path,
         batch_group_id='',
         user_tag='',
         cpu_limit="1",
         memory_limit="512M",
         container=getOption('abba.default.container'),
         mounts='',
         namespace=getOption('abba.k8s.namespace'),
         req,
         res) {

  user <- getUserMetadata(req)
  username <- user[["user"]]

  # Request may come in as empty string
  if (container == "") {
    container <- getOption('abba.default.container')
  }

  # If specified, is the container name an allowable choice?
  permitted_containers <- getOption('abba.permitted.containers')
  if (!is.null(permitted_containers) && !(container %in% permitted_containers)) {
    err_msg <-sprintf(
      "The container %s is not an permitted image. Permitted images are:\n\t- %s",
      container,
      paste0(permitted_containers, collapse = "\n\t- ")
    )

    res$status <- 400
    res$body$message = jsonlite::unbox(err_msg)
    return(list(
      message=jsonlite::unbox(err_msg),
      error=jsonlite::unbox(err_msg)
    ))
  }

  result <- abba_submit_k8s_job_local(
    file_path,
    batch_group_id=batch_group_id,
    user_tag=user_tag,
    cpu_limit=cpu_limit,
    memory_limit=memory_limit,
    container=container,
    mounts=mounts,
    username=username
  )

  return(result)
}

#* Get Job logs
#' @param job_ids list of job IDs
#' @param namespace Kubernetes namespace to put the job in
#* @get /job-log
function(job_ids,
         namespace=getOption('abba.k8s.namespace')) {

  result <- abba_get_k8s_job_log_local(job_ids,
                                       namespace=namespace)

  return(result)
}

#* Get Job logs of a batch
#' @param batch_id unique identifier for a batch
#' @param namespace Kubernetes namespace to put the job in
#* @get /batch-log
function(batch_id,
         namespace=getOption('abba.k8s.namespace')) {

  result <- abba_get_k8s_batch_log_local(batch_id,
                                         namespace=namespace)

  return(result)
}

#* Get status of every job in a batch
#* @param batch_id unique identifier for a batch
#' @param namespace Kubernetes namespace to put the job in
#* @get /batch-status
function(batch_id='',
         namespace=getOption('abba.k8s.namespace')) {

  result <- abba_get_k8s_batch_status_local(batch_id,
                                            namespace=namespace)
  return(result)
}

#* Get status of a job as a collection of statuses of its pods
#' @param job_id job id to get status for
#' @param namespace Kubernetes namespace to put the job in
#* @get /job-status
function(job_id='',
         namespace=getOption('abba.k8s.namespace')) {
  result <- abba_get_k8s_job_status_local(job_id,
                                          namespace=namespace)
  return(result)
}

#* Get the list of permitted containers available in the API
#* @get /permitted-containers
function() {
  return(sort(getOption('abba.permitted.containers')))
}
