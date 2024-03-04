options(
  abba.lower.cpu.limit=0.5,
  abba.cpu.limit = 2,
  abba.lower.memory.limit='128M',
  abba.memory.limit='1G',
  abba.api.address="http://127.0.0.1:5794",
  "plumber.port" = 5794
  )

#* Submit a job on Kubernetes
#' @param file_path Full path to R file
#' @param batch_group_id Group ID for batch processing
#' @param user_tag Optional; a string that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param container list that contains container name and image name
#' @param mounts Specifically formatted list with information bout volumes that container would have access to during the run
#* @post /submit-job
function(file_path, 
         batch_group_id='', 
         user_tag='', 
         cpu_limit="1", 
         memory_limit="512M", 
         container='', 
         mounts='') {

  result <- abba::submit_job(
    file_path,
    batch_group_id=batch_group_id,
    user_tag=user_tag,
    cpu_limit=cpu_limit,
    memory_limit=memory_limit,
    container=container,
    mounts=mounts
  )
  
  return(result)
}

#* Submit and monitor a job on Kubernetes
#' @param file_path Full path to R file
#' @param batch_group_id Group ID for batch processing
#' @param user_tag Optional; a string that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param container list that contains container name and image name
#' @param mounts Specifically formatted list with information bout volumes that container would have access to during the run
#' @param timeout_seconds Total time to wait before timeout in seconds
#' @param poll_interval_seconds Total time to wait before timeout in seconds
#* @post /submit-job-and-watch
function(file_path, 
         batch_group_id='',
         user_tag='', 
         cpu_limit="1", 
         memory_limit="512M", 
         container='', 
         mounts='',
         poll_interval_seconds = "3", 
         timeout_seconds = "14400") {
  
  
  # All args come in as character so make sure they're integers
  poll_interval_seconds <- as.integer(poll_interval_seconds)
  timeout_seconds <- as.integer(timeout_seconds)
  
  if (is.na(poll_interval_seconds)) stop("poll_interval_seconds must be provided as an integer")
  if (is.na(timeout_seconds)) stop("timeout_seconds must be provided as an integer")
  
  result <- abba::submit_job_and_poll(
    file_path,
    batch_group_id=batch_group_id,
    user_tag=user_tag,
    cpu_limit=cpu_limit,
    memory_limit=memory_limit,
    poll_interval_seconds = poll_interval_seconds,
    timeout_seconds = timeout_seconds,
    container=container,
    mounts=mounts
  )
  
  return(result)
}

#* Get Job logs
#' @param job_ids list of job IDs
#* @get /job-log
function(job_ids) {
  
  result <- abba::get_job_log(job_ids)
  
  return(result)
}

#* Get Job logs of a batch
#' @param batch_id unique identifier for a batch
#* @get /batch-log
function(batch_id) {
  
  result <- abba::get_batch_log(batch_id)
  
  return(result)
}

#* Get status of every job in a batch
#' @param batch_id unique identifier for a batch
#* @get /batch-status
function(batch_id='') {
  
  result <- abba::get_batch_status(batch_id)
  return(result)
}

#* Get status of a job as a collection of statuses of its pods
#' @param job_id job id to get status for
#* @get /job-status
function(job_id='') {
  
  result <- abba::get_job_status(job_id)
  return(result)
}