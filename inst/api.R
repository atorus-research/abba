options(
  abba.lower.cpu.limit=0.5,
  abba.cpu.limit = 2,
  abba.lower.memory.limit='128M',
  abba.memory.limit='1G'
  )

#* Submit a and monitor a job on Kubernetes
#' @param file_path Full path to R file
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param timeout_seconds Total time to wait before timeout in seconds
#* @post /submit
function(file_path, cpu_limit="1", memory_limit="512", poll_interval_seconds = "3",
         timeout_seconds = "14400") {


  # All args come in as character so make sure they're integers
  cpu_limit <- as.integer(cpu_limit)
  memory_limit <- as.integer(memory_limit)
  poll_interval_seconds <- as.integer(poll_interval_seconds)
  timeout_seconds <- as.integer(timeout_seconds)

  if (is.na(cpu_limit)) stop("cpu_limit must be provided as an integer")
  if (is.na(memory_limit)) stop("memory_limit must be provided as an integer")
  if (is.na(poll_interval_seconds)) stop("poll_interval_seconds must be provided as an integer")
  if (is.na(timeout_seconds)) stop("timeout_seconds must be provided as an integer")

  if (as.numeric(cpu_limit) > getOption('abba.cpu.limit')) {
    stop(sprintf(
      "The supplied CPU limit is greater that the maximum limit of %s CPU", getOption('abba.cpu.limit')
    ))
  }

  if (as.numeric(memory_limit) > getOption('abba.memory.limit')) {
    stop(sprintf(
      "The supplied memory limit is greater that the maximum limit of %s M", getOption('abba.memory.limit')
    ))
  }

  memory_limit_c <- paste0(memory_limit, "M")

  result <- submit_job_and_poll(
    file_path,
    cpu_limit=cpu_limit,
    memory_limit=memory_limit_c,
    poll_interval_seconds = poll_interval_seconds,
    timeout_seconds = timeout_seconds
  )

  print(result)
}

