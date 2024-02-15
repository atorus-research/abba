#' Submit a job profile for execution on a Kubernetes cluster
#'
#' @param yaml_full_path Path to YAML config file
#'
#' @return A string containing Job ID
#' @export
submit_yaml <- function(yaml_full_path){

  # send the job for execution
  system(paste("kubectl apply -f", yaml_full_path))

  # read job id from config and return it for further tracking and reporting
  yaml_config <- yaml::read_yaml(yaml_full_path)
  return(yaml_config$metadata$name)
}



#' Watch a K8S job that has been submitted to Workbench, periodically polling it's exectuion status.
#'
#' @param batch_group_id Group ID for batch processing
#' @param poll_interval_seconds Time interval for polling job status in seconds
#' @param timeout_seconds Total time to wait before timeout in seconds
#'
#' @return A "Job completed successfully" message, or a list of failed jobs and their ID's.
#' @export
#' 
#' @examples
#' result <- watch_job("safety-tfls-f0bf6848-46de-45b8-9fae-0e732b104760", 10, 3000)
#' 
watch_job <- function(batch_group_id='', poll_interval_seconds = 3, timeout_seconds = 600){
  # Initialize variables for tracking job status
  start_time <- Sys.time()
  job_statuses <- list()
  
  # Poll for job status in the specified batch group
  while (TRUE) {
    if (difftime(Sys.time(), start_time, units = "secs") > timeout_seconds) {
      break
    }
    
    # Get the status of all pods in the batch group
    command <- sprintf(
      "kubectl get pods -n rstudio -l batch-group=%s -o=jsonpath='{range .items[*]}{.metadata.name}{\"%s\"}{.status.phase}{\"\\n\"}{end}'",
      shQuote(batch_group_id), ","
    )
    job_info <- system(command, intern = TRUE)
    
    # Parse job statuses
    job_info_lines <- strsplit(job_info, "\n")[[1]]
    job_statuses <- list()
    for (line in job_info_lines) {
      parts <- unlist(strsplit(line, ","))
      if (length(parts) == 2) {
        job_name <- parts[1]
        job_status <- parts[2]
        job_statuses[[job_name]] <- job_status
      }
    }
    
    # Check the status of all jobs
    completed_jobs <- sapply(job_statuses, function(x) x == "Succeeded")
    failed_jobs <- names(job_statuses)[sapply(job_statuses, function(x) x == "Failed")]
    
    if (all(completed_jobs)) {
      return("Job completed successfully")
    } else if (length(failed_jobs) > 0) {
      break
    }
    
    # Wait for the specified interval before polling again
    Sys.sleep(poll_interval_seconds)
  }
  
  # Return the names of the failed jobs
  return(failed_jobs)
}



#' Submit a job profile for execution on a Kubernetes cluster and poll for completion
#'
#' @param file_path Full path to R file
#' @param batch_group_id Group ID for batch processing
#' @param user_tag Optional; a string that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param poll_interval_seconds Time interval for polling job status in seconds
#' @param timeout_seconds Total time to wait before timeout in seconds
#'
#' @return A "Job completed successfully" message, or a list of failed jobs and their ID's.
#' @export
#' 
#' @examples
#' result <- submit_job_and_poll("path/to/your/job.yaml", "my-batch-group", 5, 600)
#' 
submit_job_and_poll <- function(file_path, batch_group_id='', user_tag='', cpu_limit=1L, memory_limit='512M', poll_interval_seconds = 3, timeout_seconds = 600) {
  
  # Check if batch_group_id is a vector with more than one element
  if (length(batch_group_id) > 1) {
    stop("batch_group_id must be a single string value")
  }
  # By default let 'batch-group' be the lowest possible level - the program name.
  # Otherwise, keep what user has specified.
  if (is.null(batch_group_id) || batch_group_id == '') {
    batch_group_id <- unlist(strsplit(basename(file_path), '.', fixed = TRUE))[1]
    
    # Make the BATCH_GROUP_ID unique by appending the UUID to it.
    
    # Because the "group-name" doesn't need to be something unique, there is a 100% chance
    # to poll already completed jobs from past life. To prevent this we add UUID to a
    # "group-name".
    # A NOTE FOR THE GUESTS FROM THE FUTURE.
    # For multiple concurrent or parallel submissions that 'trully' may share same "group-name",
    # one should assign UUID outside of this function (at the batch level) and simply
    # pass the generated value as a parameter for this function.
    
    batch_group_id <- paste0(batch_group_id, '-', uuid::UUIDgenerate())
  }
  
  # Configure job to run our program
  job_config <- configure_yaml(file_path=file_path,
                               batch_group_id=batch_group_id,
                               user_tag=user_tag,
                               cpu_limit= cpu_limit,
                               memory_limit=memory_limit)
  
  # Save yaml to temp folders
  job_config_path <- save_yaml(job_config)
  
  # Send the job for execution and read job id
  job_id <- submit_yaml(job_config_path)
  
  result <- watch_job(batch_group_id)
  
  return(result)
  
}