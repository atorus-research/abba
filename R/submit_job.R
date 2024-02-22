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



#' Watch a K8S job that has been submitted to Workbench, periodically polling it's execution status.
#'
#' @param batch_group_id Group ID for batch processing
#' @param poll_interval_seconds Time interval for polling job status in seconds
#' @param timeout_seconds Total time to wait before timeout in seconds
#'
#' @return A "Job completed successfully" message, or a list of failed jobs and their ID's.
#' @export
#' 
#' @examples \dontrun{
#' result <- watch_job("safety-tfls-f0bf6848-46de-45b8-9fae-0e732b104760", 10, 3000)
#' }
#' 
watch_job <- function(batch_group_id='', poll_interval_seconds = 3, timeout_seconds = 600){
  # Initialize variables for tracking job status
  start_time <- Sys.time()
  job_details <- list()
  
  status_descriptions <- list(
    Pending = "The Pod has been accepted by the Kubernetes cluster, but one or more of the containers has not been set up and made ready to run. This includes time a Pod spends waiting to be scheduled as well as the time spent downloading container images over the network.",
    Running = "The Pod has been bound to a node, and all of the containers have been created. At least one container is still running, or is in the process of starting or restarting.",
    Succeeded = "All containers in the Pod have terminated in success, and will not be restarted.",
    Failed = "All containers in the Pod have terminated, and at least one container has terminated in failure. That is, the container either exited with non-zero status or was terminated by the system.",
    Unknown = "For some reason the state of the Pod could not be obtained. This phase typically occurs due to an error in communicating with the node where the Pod should be running."
  )
  
  
  # Poll for job status in the specified batch group
  while (difftime(Sys.time(), start_time, units = "secs") <= timeout_seconds) {
    
    # Get the status and args of all pods in the batch group
    command <- sprintf(
      "kubectl get pods -n rstudio -l batch-group=%s -o=jsonpath='{range .items[*]}{.metadata.name}{\",\"}{.status.phase}{\",\"}{.spec.containers[].args}{\"\\n\"}{end}'",
      shQuote(batch_group_id)
    )
    pod_info <- system(command, intern = TRUE)
    pod_lines <- unlist(strsplit(pod_info, "\n"))
    
    # Reset job_details for each iteration
    job_details <- list()
    
    for (line in pod_lines) {
      if (line != "") {
        pod_name <- get_pod_name(line)
        pod_status <- get_pod_status(line)
        program_name <- get_pod_program_name(line)
        
        # Ensure the list for this status exists
        if (!is.list(job_details[[pod_status]])) {
          job_details[[pod_status]] <- list("Jobs" = list(), "Description" = status_descriptions[[pod_status]])
        }
        
        # Append the job details
        job_details[[pod_status]]$Jobs <- c(job_details[[pod_status]]$Jobs, list(id=pod_name, path=program_name))
      }
    }
    
    
    # Get the names of the outer list in job_details
    status_names <- names(job_details)
    
    # Check if neither "Pending" nor "Running" is a name in job_details
    if (!"Pending" %in% status_names && !"Running" %in% status_names) {
      break # Break if no "Pending" or "Running" in the names of job_details
    }
    
    
    
    # Wait for the specified interval before polling again
    Sys.sleep(poll_interval_seconds)
  }
  
  return(job_details)
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
#' @examples \dontrun{
#' result <- submit_job_and_poll("path/to/your/job.yaml")
#' }
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
    # For multiple concurrent or parallel submissions that 'truly' may share same "group-name",
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