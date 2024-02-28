#' Send POST request to submit-job endpoint
#'
#' @param file_path Full path to R file
#' @param batch_group_id Group ID for batch processing
#' @param user_tag Optional; a string that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param container list that contains container name and image name
#' @param mounts Specifically formatted list with information bout volumes that container would have access to during the run
#'
#' @return body of request`s response in a list format
#' @export
#'
#' @examples \dontrun{
#' response <- send_submit_job('/path/to/R/program.R')}
send_submit_job <-
  function(file_path,
           batch_group_id='',
           user_tag='',
           cpu_limit=1L,
           memory_limit='512M',
           container='',
           mounts='') {

    # address for a submit_job_and_watch endpoint
    req <- httr2::request(paste(getOption("abba.api.address"),
                                'submit-job', sep='/'))

    # add a json body with all parameters
    req <- httr2::req_body_json(req, list(file_path=file_path,
                                          batch_group_id=batch_group_id,
                                          user_tag=user_tag,
                                          cpu_limit=cpu_limit,
                                          memory_limit=memory_limit,
                                          mounts=mounts,
                                          container=container))
    # send the request to API
    resp <- httr2::req_perform(req)

    # return response as a list
    return(httr2::resp_body_json(resp))
  }

#' Send POST request to submit-job-and-watch endpoint
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
#'
#' @return body of request`s response in a list format
#' @export
#'
#' @examples \dontrun{
#' response <- send_submit_job_and_watch('/path/to/R/program.R', batch_group_id='SDTM')}
send_submit_job_and_watch <-
  function(file_path,
           batch_group_id='',
           user_tag='',
           cpu_limit=1L,
           memory_limit='512M',
           container='',
           mounts='',
           poll_interval_seconds = 3,
           timeout_seconds = 600) {

    # address for a submit_job_and_watch endpoint
    req <- httr2::request(paste(getOption("abba.api.address"),
                                'submit-job-and-watch', sep='/'))

    # add a json body with all parameters
    req <- httr2::req_body_json(req, list(file_path=file_path,
                                          batch_group_id=batch_group_id,
                                          user_tag=user_tag,
                                          cpu_limit=cpu_limit,
                                          memory_limit=memory_limit,
                                          mounts=mounts,
                                          container=container,
                                          poll_interval_seconds=poll_interval_seconds,
                                          timeout_seconds=timeout_seconds))
    # send the request to API
    resp <- httr2::req_perform(req)

    # return response as a list
    return(httr2::resp_body_json(resp))
  }
