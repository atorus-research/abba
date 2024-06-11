#' Configure slurm submission script using it in sbatch command
#'
#' @param program_path full path to R program
#' @param log_path desirable parent folder for program's log file.
#' @param r_version Version of R that will be used to run the program. Can be specified as a full path to Rscript executable, or as a label of R version that is displayed in the Workbench GUI.
#' @param user_tag custom string that will be added to the job name.
#' @param cpu_cores Amount of CPU cores that will be requested for the job.
#' @param memory Amount of RAM in megabytes that will be requested for the job.
#' @param username user whose permission level is used to execute the script. Defaults to user submitting the job.
#' @param job_timeout time limit for a job. Must be specified in a format of "days-hours:minutes:seconds" If exceeded, job will be cancelled.
#'
#' @return a character vector representing submission script for sbatch command
#' @noRd
#'
configure_slurm_job <- function(program_path='',
                                log_path='',
                                rscript_path='',
                                user_tag='',
                                cpu_cores=getOption("abba.slurm.cpu.cores"),
                                memory=getOption("abba.slurm.memory"),
                                username=NULL,
                                job_timeout=3600
){

  slurm_config_obj <- load_slurm_template()

  program_name <- unlist(strsplit(basename(program_path), '.', fixed = TRUE))[1]

  # cannot have underscores in job name/generate name
  job_name <- gsub('_', '-', program_name)
  generate_name <- paste0(job_name, '-', uuid::UUIDgenerate())

  # Pull supplied username if provided, otherwise default to local user
  if (is.null(username)){
    service_user <- Sys.info()[["user"]]
  } else {
    service_user <- username
  }
  guid <- get_guid(user=service_user)

  # a function that would try to replace all possible keywords inside the target string
  replace_func <- function(x){
    x <- gsub("SLURM_JOB_UID", guid$uid, x)
    x <- gsub("SLURM_JOB_TIMEOUT", job_timeout, x)
    x <- gsub("CPU_CORES", cpu_cores, x)
    x <- gsub("RAM_MB", memory, x)
    x <- gsub("SLURM_JOB_JOB_NAME", generate_name, x)
    x <- gsub("PROGRAM_LOG_PATH", log_path, x)
    x <- gsub("RSCRIPT_PATH", rscript_path, x)
    x <- gsub("R_PROGRAM_PATH", program_path, x)
    x <- gsub("R_PROGRAM_FOLDER_PATH", dirname(program_path), x)
    return(x)
  }

  # recursively walk the yaml and replace all placeholders with actual values
  recursive_replace <- function(l){
    sapply(l, function(x) if(is.list(x)) recursive_replace(x)
           else if(is.character(x)) replace_func(x)
           else x, USE.NAMES = FALSE)
  }

  slurm_config_obj <- recursive_replace(slurm_config_obj)

  return(slurm_config_obj)

}


# function for submitting slurm config. Takes in a file path to config as the argument
submit_slurm_job_config <- function(slurm_config_path){
  # send the job for execution
  output <- suppressWarnings(system2(command="sbatch",
                                     args=c(slurm_config_path),
                                     stdout=TRUE, stderr=TRUE))
  slurm_command_error_check(output, "Error submitting the job.")
  # read job id from config and return it for further tracking and reporting
  return(slurm_config_get_job_id(output))
}


# function to get job log path
get_slurm_job_log_path <- function(job_id, ...){
  # get job info
  output <- suppressWarnings(system2(command="scontrol",
                                     args=c("show job", job_id),
                                     stdout=TRUE, stderr=TRUE))
  slurm_command_error_check(output, "Error getting job log path.")

  parsed_output <- slurm_parse_scontrol_output(output)

  return(parsed_output$StdOut)
}


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


# Function to determine where to place program logs depending on supplied log path/program path
slurm_config_determine_log_path <- function(log_path=NULL,
                                            program_path=NULL){
  if (is.null(program_path) || program_path == ''){
    stop(sprintf("Program_path parameter should be a real path, not %s", typeof(program_path)))
  }
  # put log file in r script folder if no log path is supplied
  prog_name <- paste0(tools::file_path_sans_ext(basename(program_path)), '.log')
  if (is.null(log_path) || log_path == ''){
    log_path <- file.path(dirname(program_path), prog_name)
  }
  # if log_path is a folder, name a log file after program name and put it in supplied log_path folder
  else if (!grepl(".", basename(log_path), fixed = TRUE)){
    log_path <- file.path(log_path, prog_name)
    }

  # if log_path is a full file path - return just log_path

  return (log_path)
}


# Function for parsing slurm config to extract job id
slurm_config_get_job_id <- function(output){
  job_id <- stringr::str_extract(output, stringr::regex("(?<=job )\\d+$"))
  return(job_id)
}
