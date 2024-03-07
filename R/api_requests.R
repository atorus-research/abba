
#' Pick up the Connect API key and add it to the request header
#'
#' @param req httr2 request object
#'
#' @return httr2 request object
#' @noRd
update_auth_headers <- function(req) {
  # Add the auth header
  connectAPIKey <- Sys.getenv("CONNECT_API_KEY")
  if (connectAPIKey != "") {
    req <- httr2::req_headers(req, Authorization = paste0("Key ", connectAPIKey))
  } else {
    warning("No API key has been saved in the CONNECT_API_KEY environment variable.")
  }
  req
}

#' Submit a job to an available abba API
#'
#' @param file_path Full path to R file
#' @param batch_group_id Group ID for batch processing
#' @param user_tag Optional; a string that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param container list that contains container name and image name
#' @param mounts Specifically formatted list with information bout volumes that container would have access to during the run
#' @param api_address IP address to send requests to
#'
#' @return Job / Batch ID identifier in a list object
#' @export
#'
#' @examples \dontrun{
#' response <- abba_submit_job('/path/to/R/program.R')}
abba_submit_job <-
  function(file_path,
           batch_group_id='',
           user_tag='',
           cpu_limit=1L,
           memory_limit='512M',
           container='',
           mounts='',
           api_address=getOption("abba.api.address")) {

    # address for a submit_job_and_watch endpoint
    req <- httr2::request(paste(api_address,
                                'submit-job', sep='/'))

    # Auth headers
    req <- update_auth_headers(req)

    # add a json body with all parameters
    req <- httr2::req_body_json(req, list(file_path=file_path,
                                          batch_group_id=batch_group_id,
                                          user_tag=user_tag,
                                          cpu_limit=cpu_limit,
                                          memory_limit=memory_limit,
                                          mounts=mounts,
                                          container=container))
    # send the request to API
    resp <- httr2::req_error(req, body = submit_job_error_body) %>% httr2::req_perform()
    result <- httr2::resp_body_json(resp)
    # unlist values inside the results
    result$job_id <- unlist(result$job_id)
    result$batch_id <- unlist(result$batch_id)
    # return response as a list
    return(result)
  }


#' Send job and poll for status. This function sends multiple requests so it won't
#' time out on heavy jobs
#'
#' @param file_path Full path to R file
#' @param batch_group_id Group ID for batch processing
#' @param user_tag Optional; a string that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param container list that contains container name and image name
#' @param mounts Specifically formatted list with information bout volumes that container would have access to during the run
#' @param timeout_seconds Total time to wait before timeout in seconds
#' @param poll_interval_seconds Total time to wait before timeout in seconds
#' @param api_address IP address to send requests to
#'
#' @return list with 2 attributes: job_id for submitted job`s id, and its logs
#' @export
#'
#' @examples \dontrun{
#' response <- abba_submit_and_get_log('/path/to/R/program.R', batch_group_id='SDTM')}
abba_submit_and_get_log <-
  function(file_path,
           batch_group_id='',
           user_tag='',
           cpu_limit=1L,
           memory_limit='512M',
           container='',
           mounts='',
           poll_interval_seconds = 3,
           timeout_seconds = 600,
           api_address=getOption("abba.api.address")) {

    # submit the job
    job_id <- abba_submit_job(file_path=file_path,
                              batch_group_id=batch_group_id,
                              user_tag=user_tag,
                              cpu_limit=cpu_limit,
                              memory_limit=memory_limit,
                              mounts=mounts,
                              container=container)

    start_time <- Sys.time()

    # Poll for job status in the specified batch group
    while (difftime(Sys.time(), start_time, units = "secs") <= timeout_seconds) {

      # Get the status
      job_details <- abba_get_job_status(job_id$job_id, api_address=api_address)

      # Get the names of the outer list in job_details
      status_names <- names(job_details)

      # Check if neither "Pending" nor "Running" is a name in job_details
      if (!"Pending" %in% status_names && !"Running" %in% status_names) {
        break # Break if no "Pending" or "Running" in the names of job_details
      }

      # Wait for the specified interval before polling again
      Sys.sleep(poll_interval_seconds)
    }

    # get logs after job is no long in pending/running stage
    program_name <- tools::file_path_sans_ext(basename(job_details[[1]]$Jobs[[1]]$path))
    logs <- abba_get_job_log(job_id$job_id, api_address = api_address)
    result = list()
    result[[program_name]] = logs[[1]]
    # return response as a list
    return(result)
  }


#' Monitor job status and retrieve its log when the job finishes running
#'
#' @param job_id unique job identificator
#' @param timeout_seconds Total time to wait before timeout in seconds
#' @param poll_interval_seconds Total time to wait before timeout in seconds
#' @param api_address IP address to send requests to
#'
#' @return list with 2 attributes: job_id for submitted job`s id, and its logs
#' @export
#'
#' @examples \dontrun{
#' response <- abba_wait_for_job_log('sdfj4-asdjlk-bjslk')}
abba_wait_for_job_log <-
  function(job_id,
           poll_interval_seconds = 3,
           timeout_seconds = 600,
           api_address=getOption("abba.api.address")) {

    start_time <- Sys.time()

    # Poll for job status in the specified batch group
    while (difftime(Sys.time(), start_time, units = "secs") <= timeout_seconds) {

      # Get the status
      job_details <- abba_get_job_status(job_id, api_address=api_address)

      # Get the names of the outer list in job_details
      status_names <- names(job_details)

      # Check if neither "Pending" nor "Running" is a name in job_details
      if (!"Pending" %in% status_names && !"Running" %in% status_names) {
        break # Break if no "Pending" or "Running" in the names of job_details
      }

      # Wait for the specified interval before polling again
      Sys.sleep(poll_interval_seconds)
    }

    # get logs after job is no long in pending/running stage
    logs <- abba_get_job_log(job_id, api_address = api_address)

    # return response as a list
    return(logs)
  }


#' Monitor batch status and retrieve its log when the all jobs in batch finish running
#'
#' @param batch_id unique batch identificator
#' @param timeout_seconds Total time to wait before timeout in seconds
#' @param poll_interval_seconds Total time to wait before timeout in seconds
#' @param api_address IP address to send requests to
#'
#' @return list with 2 sublists: job_ids and their logs
#' @export
#'
#' @examples \dontrun{
#' response <- abba_wait_for_batch_log('batch-sdtm-sdfj4-asdjlk-bjslk')}
abba_wait_for_batch_log <-
  function(batch_id,
           poll_interval_seconds = 3,
           timeout_seconds = 600,
           api_address=getOption("abba.api.address")) {

    start_time <- Sys.time()

    # Poll for job status in the specified batch group
    while (difftime(Sys.time(), start_time, units = "secs") <= timeout_seconds) {

      # Get the status
      batch_details <- abba_get_batch_status(batch_id, api_address=api_address)

      # Get the names of the outer list in job_details
      status_names <- names(batch_details)

      # Check if neither "Pending" nor "Running" is a name in job_details
      if (!"Pending" %in% status_names && !"Running" %in% status_names) {
        break # Break if no "Pending" or "Running" in the names of job_details
      }

      # Wait for the specified interval before polling again
      Sys.sleep(poll_interval_seconds)
    }

    # get logs after job is no long in pending/running stage
    logs <- abba_get_batch_log(batch_id, api_address = api_address)

    # return response as a list
    return(logs)
  }


#' Send GET request to get logs of specified Jobs
#'
#' @param job_ids A list of job IDs to get logs for
#' @param api_address IP address to send requests to
#'
#' @return body of request`s response in a list format
#' @export
#'
#' @examples \dontrun{
#' response <- abba_get_job_log('1234j-13j4l5k-ajslfd')}
abba_get_job_log <-
  function(job_ids, api_address=getOption("abba.api.address")) {

    # address for a submit_job_and_watch endpoint
    req <- httr2::request(paste(api_address, 'job-log', sep='/'))
    req <- update_auth_headers(req)

    # add a json body with all parameters
    req <- httr2::req_body_json(req, list(job_ids=job_ids)) %>% httr2::req_method("GET")
    # send the request to API
    resp <- httr2::req_error(req, body = submit_job_error_body) %>% httr2::req_perform()
    result <- httr2::resp_body_json(resp)
    # unlist the log
    for (i in 1:length(result)){
      result[[i]]$job_id <- unlist(result[[i]]$job_id)
      result[[i]]$log <- unlist(result[[i]]$log)
    }
    # return response as a list
    return(result)
  }


#' Send GET request to get logs of all jobs in a batch
#'
#' @param batch_id unique batch identificator
#' @param api_address IP address to send requests to
#'
#' @return body of request`s response in a list format
#' @export
#'
#' @examples \dontrun{
#' response <- abba_get_job_log('1234j-13j4l5k-ajslfd')}
abba_get_batch_log <-
  function(batch_id, api_address=getOption("abba.api.address")) {

    # address for a submit_job_and_watch endpoint
    req <- httr2::request(paste(api_address, 'batch-log', sep='/'))
    req <- update_auth_headers(req)

    # add a json body with all parameters
    req <- httr2::req_body_json(req, list(batch_id=batch_id)) %>% httr2::req_method("GET")
    # send the request to API
    resp <- httr2::req_error(req, body = submit_job_error_body) %>% httr2::req_perform()
    result <- httr2::resp_body_json(resp)
    # unlist the log
    for (i in 1:length(result)){
      result[[i]]$pod_id <- unlist(result[[i]]$pod_id)
      result[[i]]$log <- unlist(result[[i]]$log)
    }
    # return response as a list
    return(result)
  }


#' Send GET request to get batch job statuses
#'
#' @param batch_id batch ID to get status for
#' @param api_address IP address to send requests to
#'
#' @return body of request`s response in a list format
#' @export
#'
#' @examples \dontrun{
#' response <- abba_get_batch_status('1234j-13j4l5k-ajslfd')}
abba_get_batch_status <-
  function(batch_id, api_address=getOption("abba.api.address")) {

    # address for a submit_job_and_watch endpoint
    req <- httr2::request(paste(api_address, 'batch-status', sep='/'))
    req <- update_auth_headers(req)

    # add a json body with all parameters
    req <- httr2::req_body_json(req, list(batch_id=batch_id)) %>% httr2::req_method("GET")
    # send the request to API
    resp <- httr2::req_error(req, body = submit_job_error_body) %>% httr2::req_perform()

    # return response as a list
    result <- httr2::resp_body_json(resp)
    # unlist id and path
    statuses <- names(result)
    for (status in statuses){
      for (i in 1:length(result[[status]]$Jobs)){
        for (name in names(result[[status]]$Jobs[[i]])){
          result[[status]]$Jobs[[i]][[name]]=unlist(result[[status]]$Jobs[[i]][[name]])
        }
      }
    }

    return(result)
  }

#' Send GET request to get job status
#'
#' @param job_id job IDs to get status for
#' @param api_address IP address to send requests to
#'
#' @return body of request`s response in a list format
#' @export
#'
#' @examples \dontrun{
#' response <- abba_get_job_status('1234j-13j4l5k-ajslfd')}
abba_get_job_status <-
  function(job_id, api_address=getOption("abba.api.address")) {

    # address for a submit_job_and_watch endpoint
    req <- httr2::request(paste(api_address, 'job-status', sep='/'))
    req <- update_auth_headers(req)

    # add a json body with all parameters
    req <- httr2::req_body_json(req, list(job_id=job_id)) %>% httr2::req_method("GET")
    # send the request to
    resp <- httr2::req_error(req, body = submit_job_error_body) %>% httr2::req_perform()

    # return response as a list
    result <- httr2::resp_body_json(resp)
    # unlist id and path
    statuses <- names(result)
    for (status in statuses){
      for (i in 1:length(result[[status]]$Jobs)){
        for (name in names(result[[status]]$Jobs[[i]])){
          result[[status]]$Jobs[[i]][[name]]=unlist(result[[status]]$Jobs[[i]][[name]])
        }
      }
    }

    return(result)
  }

#' Function used to extract error message from response body
#'
#' @param resp httr2`s response
#'
#' @return message attribute from response body
#' @noRd
submit_job_error_body <- function(resp) {
  httr2::resp_body_json(resp)$message
}
