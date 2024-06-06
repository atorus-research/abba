# decude slurm statuses
decode_slurm_job_status <- function(short_job_status){
  job_statuses <- list(BF  = "BOOT_FAIL",
                       CA  = "CANCELLED",
                       CD  = "COMPLETED",
                       CF  = "CONFIGURING",
                       CG  = "COMPLETING",
                       DL  = "DEADLINE",
                       F   = "FAILED",
                       NF  = "NODE_FAIL",
                       OOM = "OUT_OF_MEMORY",
                       PD  = "PENDING",
                       PR  = "PREEMPTED",
                       R   = "RUNNING",
                       RD  = "RESV_DEL_HOLD",
                       RF  = "REQUEUE_FED",
                       RH  = "REQUEUE_HOLD",
                       RQ  = "REQUEUED",
                       RS  = "RESIZING",
                       RV  = "REVOKED",
                       SI  = "SIGNALING",
                       SE  = "SPECIAL_EXIT",
                       SO  = "STAGE_OUT",
                       ST  = "STOPPED",
                       S   = "SUSPENDED",
                       TO  = "TIMEOUT")
  return (job_statuses[[short_job_status]])
}


# simple function to get slurm job status. Relies on configured SLURM accounting
slurm_get_job_status_sacct0 <- function(job_id, ...){
  output <- suppressWarnings(system2(command="sacct",
                                     args=c(" -j", job_id, "--format=JobID,ExitCode,State"),
                                     stdout=TRUE, stderr=TRUE))

  err_msg <- if(is.null(attr(output, "errmsg"))) "No error message provided" else attr(output, "errmsg")
  if (attr(output, "status") != 0){
    stop(sprintf("Error getting job status. %s.\nError message: %s", output, err_msg))
  }
  # get first line after headers
  job_info <- output[[3]]

  # split words in job_info string by spaces. Expected result is 3 words(job id, exit code, and state)
  status <- strsplit(job_info, "\\s+")[[1]]
  return(status[[length(status)]])
}


# parse the StdOut path from scontrol command output
slurm_parse_scontrol_output <- function(output){
  # only easily parsed information is currently retained
  parsed_output <- stringr::str_split(stringr::str_trim(output), " ", simplify=TRUE) %>%
    .[stringr::str_count(., "=") == 1]

  split_output <- stringr::str_split(parsed_output, "=")

  output_names <- sapply(split_output, function(x){x[[1]]})
  output_values <- lapply(split_output, function(x){x[[2]]})

  # create a named list with names being job attribute/parameter names
  setNames(object=output_values, output_names)
}


# parse the StdOut path from scontrol command output
slurm_parse_squeue_output <- function(output){
  # squeue output is structured like a csv file with whitespace delimiter
  read.table(text=output, header=TRUE, sep="")

}


# check if command executed via system2 produced any errors
slurm_command_error_check <- function(cmd_output, msg){
  err_msg <- if(is.null(attr(cmd_output, "errmsg"))) "" else paste("Error details:", attr(cmd_output, "errmsg"))
  if (!is.null(attr(cmd_output, "status")) && attr(cmd_output, "status") != 0){
    stop(sprintf(paste0(msg, " %s.\n%s"), cmd_output, err_msg))
  }
}
