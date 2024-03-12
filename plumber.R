library(plumber)
devtools::load_all()

options(
  abba.lower.cpu.limit=0.5,
  abba.cpu.limit = 2,
  abba.lower.memory.limit='128M',
  abba.memory.limit='1G',
  abba.permitted.containers = c("atoruscontainers.azurecr.io/openval_4.2.1_focal:2023.09.0.02",
                                "atoruscontainers.azurecr.io/openval_4.2.1_focal:latest",
                                "atoruscontainers.azurecr.io/openval_base_4.3.2_focal:2024.03.01",
                                "atoruscontainers.azurecr.io/openval_base_4.3.2_focal:latest",
                                "atoruscontainers.azurecr.io/openval-dev-focal:latest"),
  abba.default.container = "atoruscontainers.azurecr.io/openval_4.2.1_focal:2023.09.0.02"
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
#* @post /submit-job
function(file_path,
         batch_group_id='',
         user_tag='',
         cpu_limit="1",
         memory_limit="512M",
         container=getOption('abba.default.container'),
         mounts='',
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
#* @get /job-log
function(job_ids) {

  result <- abba_get_k8s_job_log_local(job_ids)

  return(result)
}

#* Get Job logs of a batch
#' @param batch_id unique identifier for a batch
#* @get /batch-log
function(batch_id) {

  result <- abba_get_k8s_batch_log_local(batch_id)

  return(result)
}

#* Get status of every job in a batch
#* @param batch_id unique identifier for a batch
#* @get /batch-status
function(batch_id='') {

  result <- abba_get_k8s_batch_status_local(batch_id)
  return(result)
}

#* Get status of a job as a collection of statuses of its pods
#' @param job_id job id to get status for
#* @get /job-status
function(job_id='') {
  result <- abba_get_k8s_job_status_local(job_id)
  return(result)
}

#* Get the list of permitted containers available in the API
#* @get /permitted-containers
function() {
  return(sort(getOption('abba.permitted.containers')))
}
