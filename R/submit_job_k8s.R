#' Submit a job profile for execution on a Kubernetes cluster
#'
#' @param yaml_full_path Path to YAML config file
#'
#' @return A string containing Job ID
#' @export
#'
#' @examples \dontrun{
#' job_id <- submit_k8s_yaml("/tmp/my_job.yaml")
#' }
submit_k8s_yaml <- function(yaml_full_path){

  # send the job for execution
  suppressWarnings(system2(command="kubectl",
                           args=c("apply", "-f" , yaml_full_path),
                           stdout=TRUE, stderr=TRUE))
  # read job id from config and return it for further tracking and reporting
  yaml_config <- yaml::read_yaml(yaml_full_path)
  return(yaml_config$metadata$name)
}


#' Get status of all pods that belong to a job or batch
#'
#' @param unit_id unique identifier for a job/batch
#' @param namespace Kubernetes namespace
#' @param unit_type type of unit - can be 'job' or 'batch'
#' @return list of statuses for every pod in a job/batch.
#' @noRd
#'
abba_get_k8s_unit_status_local <- function(unit_id, unit_type='job', namespace=getOption('abba.k8s.namespace')){

  status_descriptions <- list(
    Pending = "The Pod has been accepted by the Kubernetes cluster, but one or more of the containers has not been set up and made ready to run. This includes time a Pod spends waiting to be scheduled as well as the time spent downloading container images over the network.",
    Running = "The Pod has been bound to a node, and all of the containers have been created. At least one container is still running, or is in the process of starting or restarting.",
    Succeeded = "All containers in the Pod have terminated in success, and will not be restarted.",
    Failed = "All containers in the Pod have terminated, and at least one container has terminated in failure. That is, the container either exited with non-zero status or was terminated by the system.",
    Unknown = "For some reason the state of the Pod could not be obtained. This phase typically occurs due to an error in communicating with the node where the Pod should be running."
  )
  job_details <- list()

  # determine selector depending on unit_type
  validate_unit_type(unit_type)
  if (unit_type=='job') {unit_selector <- "--selector=batch.kubernetes.io/job-name"}
  else if (unit_type=='batch') {unit_selector <- "-l batch-group"}
  # Get the status and args of all pods in the batch group
  cmd_args <- sprintf("get pods -n %s %s=%s -o=jsonpath='{range .items[*]}{.metadata.name}{\",\"}{.status.phase}{\",\"}{.spec.containers[].args}{\"\\n\"}{end}'",
                      namespace, unit_selector, shQuote(unit_id))
  pod_info <- suppressWarnings(system2("kubectl",
                                       args=cmd_args,
                                       stdout=TRUE, stderr=TRUE))
  pod_lines <- unlist(strsplit(pod_info, "\n"))

  # Reset job_details for each iteration
  job_details <- list()

  for (line in pod_lines) {
    if (line != "") {
      pod_name <- get_k8s_pod_name(line)
      pod_status <- get_k8s_pod_status(line)
      program_name <- get_k8s_pod_program_name(line)

      # Ensure the list for this status exists
      if (!is.list(job_details[[pod_status]])) {
        job_details[[pod_status]] <- list("Jobs" = list(), "Description" = status_descriptions[[pod_status]])
      }

      # Append the job details
      job_details[[pod_status]]$Jobs <-
        c(job_details[[pod_status]]$Jobs,
          list(list(id=unlist(pod_name),
                    path=unlist(program_name))))
    }
  }

  return(job_details)
}

#' Get status of all pods that belong to a job
#'
#' @param job_id unique identifier for a job
#' @param namespace Kubernetes namespace
#'
#' @return list of statuses for every pod in a job(typically just one).
#' @export
#'
#' @examples \dontrun{
#' status <- abba_get_k8s_job_status_local("job-sdtm-abc123")
#' }
abba_get_k8s_job_status_local <- function(job_id, namespace=getOption('abba.k8s.namespace')){

  job_details <- abba_get_k8s_unit_status_local(unit_id=job_id, unit_type='job', namespace=namespace)

  return(job_details)
}


#' Get status of all jobs in a batch
#'
#' @param batch_id unique identifier for a batch
#' @param namespace Kubernetes namespace
#'
#' @return list of statuses for every job in a batch
#' @export
#'
#' @examples \dontrun{
#' status <- abba_get_k8s_batch_status_local("batch-sdtm-abc123")
#' }
abba_get_k8s_batch_status_local <- function(batch_id, namespace=getOption('abba.k8s.namespace')){

  job_details <- abba_get_k8s_unit_status_local(unit_id=batch_id, unit_type='batch', namespace=namespace)

  return(job_details)
}


#' Watch a K8S job/batch that has been submitted to Workbench, periodically polling it's execution status.
#'
#' @param unit_id job/batch ID that was specified when submitting job/batch
#' @param unit_type specify whether to watch a job or a batch
#' @param poll_interval_seconds Time interval for polling batch status in seconds
#' @param timeout_seconds Total time to wait before timeout in seconds
#' @param namespace Kubernetes namespace
#'
#' @return a list of job ID(s) and status(es)
#' @noRd
#'
#' @examples \dontrun{
#' result <- abba_watch_k8s_unit_local("safety-tfls-f0bf6848-46de-45b8-9fae-0e732b104760", 10, 3000)
#' }
#'
abba_watch_k8s_unit_local <- function(unit_id='',
                                      unit_type='job',
                                      poll_interval_seconds = 3,
                                      timeout_seconds = 600,
                                      namespace=getOption('abba.k8s.namespace')){
  # Initialize variables for tracking job status
  start_time <- Sys.time()

  validate_unit_type(unit_type)
  if (unit_type=='job'){get_status <- abba_get_k8s_job_status_local}
  else if (unit_type=='batch'){get_status <- abba_get_k8s_batch_status_local}
  # Poll for job status in the specified batch group
  while (difftime(Sys.time(), start_time, units = "secs") <= timeout_seconds) {

    job_details <- get_status(unit_id, namespace=namespace)

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


#' Watch a K8S batch that has been submitted to Workbench, periodically polling it's execution status.
#'
#' @param batch_group_id Batch ID that was specified when submitting a group of jobs
#' @param poll_interval_seconds Time interval for polling batch status in seconds
#' @param timeout_seconds Total time to wait before timeout in seconds
#' @param namespace Kubernetes namespace
#'
#' @return a list of jobs IDs and statuses that belong to batch named batch_group_id
#' @export
#'
#' @examples \dontrun{
#' result <- abba_watch_k8s_batch_local("safety-tfls-f0bf6848-46de-45b8-9fae-0e732b104760", 10, 3000)
#' }
#'
abba_watch_k8s_batch_local <- function(batch_group_id='',
                                       poll_interval_seconds = 3,
                                       timeout_seconds = 600,
                                       namespace=getOption('abba.k8s.namespace')){

  job_details <- abba_watch_k8s_unit_local(unit_id=batch_group_id,
                                           unit_type='batch',
                                           poll_interval_seconds=poll_interval_seconds,
                                           timeout_seconds=timeout_seconds,
                                           namespace=namespace)

  return(job_details)
}


#' Watch a K8S job that has been submitted to Workbench, periodically polling it's execution status.
#'
#' @param job_id Job ID. Typically obtained as a return value from submit_job and similar functions
#' @param poll_interval_seconds Time interval for polling job status in seconds
#' @param timeout_seconds Total time to wait before timeout in seconds
#' @param namespace Kubernetes namespace
#'
#' @return a list of pods, their IDs and execution statuses
#' @export
#'
#' @examples \dontrun{
#' result <- abba_watch_k8s_job_local("job-sdtm-f0bf6848-46de-45b8-9fae-0e732b104760", 10, 3000)
#' }
#'
abba_watch_k8s_job_local <- function(job_id='',
                                     poll_interval_seconds = 3,
                                     timeout_seconds = 600,
                                     namespace=getOption('abba.k8s.namespace')){

  job_details <- abba_watch_k8s_unit_local(unit_id=job_id,
                                           unit_type='job',
                                           poll_interval_seconds=poll_interval_seconds,
                                           timeout_seconds=timeout_seconds,
                                           namespace=namespace)

  return(job_details)
}


#' Submit an R program for execution on a Kubernetes cluster
#'
#' @param file_path Full path to R file
#' @param batch_group_id Group ID for batch processing
#' @param user_tag Optional; a string that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param container A valid container image name provided as a character string. Defaults to the option abba.default.container.
#' @param mounts Specifically formatted list with information bout volumes that container would have access to during the run
#' @param auto_mount_home set to TRUE to mount service user home directory
#' @param home_nfs_ip_address IP address for mounting service user home directory
#' @param namespace Kubernetes namespace to put the job in
#' @param username user whose authority will be used to run the program
#'
#' @return A list with job_id and batch_id attributes in case of successful submission
#' @export
#'
#' @examples \dontrun{
#' job_info <- abba_submit_k8s_job_local("path/to/your/program.R", batch_group_id='SDTM')
#' }
#'
abba_submit_k8s_job_local <- function(file_path,
                                      batch_group_id='',
                                      user_tag='',
                                      cpu_limit=1L,
                                      memory_limit='512M',
                                      container=getOption('abba.default.container'),
                                      mounts='',
                                      auto_mount_home=FALSE,
                                      home_nfs_ip_address=getOption('abba.home.nfs.ip.address'),
                                      namespace=getOption('abba.k8s.namespace'),
                                      username=NULL) {

  # Check if batch_group_id is a vector with more than one element
  validate_batch_id(batch_group_id)
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
  job_config <- configure_k8s_yaml(file_path=file_path,
                                   batch_group_id=batch_group_id,
                                   user_tag=user_tag,
                                   cpu_limit= cpu_limit,
                                   memory_limit=memory_limit,
                                   container=container,
                                   mounts=mounts,
                                   namespace=namespace,
                                   username=username,
                                   auto_mount_home=auto_mount_home,
                                   home_nfs_ip_address=home_nfs_ip_address
                                   )

  # Save yaml to temp folders
  job_config_path <- save_yaml(job_config)

  # Send the job for execution and read job id
  job_id <- submit_k8s_yaml(job_config_path)

  return(list(job_id=job_id, batch_id=batch_group_id))

}

#' Submit a job profile for execution on a Kubernetes cluster and poll for completion
#'
#' @param file_path Full path to R file
#' @param batch_group_id Group ID for batch processing
#' @param user_tag Optional; a string that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param container A valid container image name provided as a character string. Defaults to the option abba.default.container.
#' @param mounts Specifically formatted list with information bout volumes that container would have access to during the run
#' @param auto_mount_home set to TRUE to mount service user home directory
#' @param home_nfs_ip_address IP address for mounting service user home directory
#' @param namespace Kubernetes namespace to put the job in
#' @param username user whose authority will be used to run the program
#' @param poll_interval_seconds Time interval for polling job status in seconds
#' @param timeout_seconds Total time to wait before timeout in seconds
#'
#' @return A "Job completed successfully" message, or a list of failed jobs and their ID's.
#' @export
#'
#' @examples \dontrun{
#' result <- abba_submit_k8s_job_and_poll_local("path/to/your/job.yaml")
#' }
#'
#'
abba_submit_k8s_job_and_poll_local <- function(file_path,
                                               batch_group_id='',
                                               user_tag='',
                                               cpu_limit=1L,
                                               memory_limit='512M',
                                               container=getOption('abba.default.container'),
                                               mounts='',
                                               auto_mount_home=FALSE,
                                               home_nfs_ip_address=getOption('abba.home.nfs.ip.address'),
                                               namespace=getOption('abba.k8s.namespace'),
                                               username=NULL,
                                               poll_interval_seconds = 3,
                                               timeout_seconds = 600) {

  # Send the job for execution and read job id
  job_info <- abba_submit_k8s_job_local(file_path=file_path,
                                        batch_group_id=batch_group_id,
                                        user_tag=user_tag,
                                        cpu_limit=cpu_limit,
                                        memory_limit=memory_limit,
                                        container=container,
                                        mounts=mounts,
                                        namespace=namespace,
                                        username=username,
                                        auto_mount_home=auto_mount_home,
                                        home_nfs_ip_address=home_nfs_ip_address)

  result <- abba_watch_k8s_job_local(job_info$job_id,
                                     poll_interval_seconds = poll_interval_seconds,
                                     timeout_seconds = timeout_seconds,
                                     namespace=namespace)

  return(result)

}
