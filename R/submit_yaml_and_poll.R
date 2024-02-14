#' Submit a job profile for execution on a Kubernetes cluster and poll for completion
#'
#' @param yaml_full_path Path to YAML config file
#' @param batch_group_id Group ID for batch processing
#' @param poll_interval_seconds Time interval for polling job status in seconds
#' @param timeout_seconds Total time to wait before timeout in seconds
#'
#' @return A list containing job IDs and their final status
#' @export
#' @noRd
#' 
#' @examples
#' result <- submit_yaml_and_poll("path/to/your/job.yaml", "my-batch-group", 5, 600)
#' 
submit_yaml_and_poll <- function(yaml_full_path, batch_group_id, poll_interval_seconds = 5, timeout_seconds = 600) {
  
  # Send the job for execution and read job id
  job_id <- submit_yaml(yaml_full_path)
  
  # Add the job to the batch group (this requires your YAML to have a label for batch grouping)
  system(paste("kubectl label jobs", job_id, "batch-group=" , batch_group_id, "--overwrite"))
  
  # Initialize variables for tracking job status
  start_time <- Sys.time()
  job_statuses <- list()
  
  # Poll for job status in the specified batch group
  while (TRUE) {
    if (difftime(Sys.time(), start_time, units = "secs") > timeout_seconds) {
      break
    }
    
    # Get the status of all jobs in the batch group
    command <- paste("kubectl get jobs -l batch-group=", batch_group_id, "-o=jsonpath='{.items[*].metadata.name}{\"\\t\"}{.items[*].status.conditions[?(@.type==\"Complete\")].status}{\"\\n\"}'", sep="")
    job_info <- system(command, intern = TRUE)
    
    # Parse job statuses
    job_info_lines <- strsplit(job_info, "\n")[[1]]
    for (line in job_info_lines) {
      parts <- unlist(strsplit(line, "\t"))
      job_name <- parts[1]
      job_status <- parts[2]
      job_statuses[[job_name]] <- job_status
    }
    
    # Check if all jobs are completed
    if (all(sapply(job_statuses, function(x) x == "True"))) {
      break
    }
    
    # Wait for the specified interval before polling again
    Sys.sleep(poll_interval_seconds)
  }
  
  return(job_statuses)
}
