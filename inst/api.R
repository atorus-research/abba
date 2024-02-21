options(
  abba.cpu.limit = 8,
  abba.memory.limit = 32000
)

#* Submit a and monitor a job on Kubernetes
#' @param file_path Full path to R file
#' @param batch_group_id Group ID for batch processing
#' @param user_tag Optional; a string that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param poll_interval_seconds Time interval for polling job status in seconds
#' @param timeout_seconds Total time to wait before timeout in seconds
#* @post /submit
function(file_path, batch_group_id='', user_tag='', cpu_limit=1L,
         memory_limit=512L, poll_interval_seconds = 3L, timeout_seconds = 600L) {

  if (as.numeric(cpu_limit) > getOption('abba.cpu.limit')) {
    stop(sprintf(
      "The supplied CPU limit is greater that the maximum limit of %s CPU", getOption('abba.cpu.limit')
    ))
  }

  print(memory_limit)
  print(getOption('abba.memory.limit'))

  if (as.numeric(memory_limit) > getOption('abba.memory.limit')) {
    stop(sprintf(
      "The supplied memory limit is greater that the maximum limit of %s M", getOption('abba.memory.limit')
    ))
  }

  return(
    list(file_path, batch_group_id, user_tag, cpu_limit,
    memory_limit, poll_interval_seconds, timeout_seconds)
  )

  # submit_job_and_poll(
  #   file_path,
  #   batch_group_id=batch_group_id,
  #   user_tag=user_tag,
  #   cpu_limit=cpu_limit,
  #   memory_limit=memory_limit,
  #   poll_interval_seconds = poll_interval_seconds,
  #   timeout_seconds = timeout_seconds
  # )
}

