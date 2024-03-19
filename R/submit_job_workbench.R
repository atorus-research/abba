submit_workbench_job <- function(p, wait=FALSE, log_path=NA, user_tag='', ...) {
  # Submit the job for the program and wait until its execution
  scriptPath <- path.expand(p)
  scriptFile <- basename(scriptPath)
  scriptArg <- paste("-f", scriptPath)
  jobTag <- paste("rstudio-r-script-job", scriptFile, sep = ":")

  # put log file in r script folder if no log path is supplied
  if (is.na(log_path) || log_path == ''){
    log_path=file.path(dirname(scriptPath), paste0(tools::file_path_sans_ext(basename(scriptPath)), '.log'))
  } else {log_path=file.path(log_path, paste0(tools::file_path_sans_ext(basename(scriptPath)), '.log'))}

  # don't pass any arguments for SubmitJob for now
  job_id <- rstudioapi::launcherSubmitJob(args =  c("--slave", "--no-save", "--no-restore", scriptArg),
                                          cluster = 'Local',
                                          command = "R",
                                          stdoutFile = log_path,
                                          stderrFile = log_path,
                                          name = scriptPath,
                                          tags = c(jobTag)
  )

  status <- get_workbench_job_status(job_id)
  # Watch the job while it's executing
  if (wait){
    job_id <- wait_for_workbench_job_completion(job_id)
  }
  # return path of the executed script along with execution status(anything other than 0 is a failure)
  return(job_id)

}

submit_logrx_workbench_job <- function(p, wait=FALSE, log_path=NA, user_tag='', ...) {

  # Submit the job for the program and wait until its execution
  scriptPath <- path.expand(p)
  scriptFile <- basename(scriptPath)
  scriptArg <- sprintf("-f %s --args %s", system.file('logrx_workbench_submission.R', package="abba"), scriptPath)
  jobTag <- paste("rstudio-r-script-job", scriptFile, sep = ":")
  if (is.na(log_path) || log_path == ''){
    log_path=file.path(dirname(scriptPath), paste0(tools::file_path_sans_ext(basename(scriptPath)), '.log'))
  } else {log_path=file.path(log_path, paste0(tools::file_path_sans_ext(basename(scriptPath)), '.log'))}

  # don't pass any arguments for SubmitJob for now
  job_id <- rstudioapi::launcherSubmitJob(args =  c("--slave", "--no-save", "--no-restore", scriptArg),
                                          cluster = 'Local',
                                          command = "R",
                                          name = scriptPath,
                                          tags = c(jobTag)
  )

  status <-  get_workbench_job_status(job_id)
  # Watch the job while it's executing
  if (wait){
    job_id <- wait_for_workbench_job_completion(job_id)
    }
  }
  # return ID assosicated with submitted program
  return(job_id)

# simple function to get the job status
get_workbench_job_status <- function(job_ids){
  return(sapply(job_ids, function(x) rstudioapi::launcherGetJob(x)[['status']]))
}

# function that periodically polls job-id for status and returns its id when job
# status reaches 'Finished' state
wait_for_workbench_job_completion <- function(job_ids,
                                              poll_interval_seconds = 1,
                                              timeout_seconds = 100){
  # Initialize variables for tracking job status
  start_time <- Sys.time()

  # Watch the job while it's executing
  while (difftime(Sys.time(), start_time, units = "secs") <= timeout_seconds) {

    statuses <- get_workbench_job_status(job_ids)
    # Check if job has finished running
    if (all(statuses == "Finished")) {
      break # Break if job has reached 'Finished' status
    }
    # Wait for the specified interval before polling again
    Sys.sleep(poll_interval_seconds)
  }
  return(job_ids)
}

# simple function to get job log
get_workbench_job_log0 <- function(job_id){
  job_info <- rstudioapi::launcherGetJob(job_id)

  if (!file.exists(job_info$stdoutFile)){
    return(c(sprintf('Log file does not exist for %s', job_info$id)))
  }

  return(readLines(con=job_info$stdoutFile))
}

# vectorized version of get_workbench_job_log0
get_workbench_job_log <- function(job_ids){
  return(lapply(job_ids, get_workbench_job_log0))
}
