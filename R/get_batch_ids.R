#' Get IDs for all jobs marked with a given batch id
#'
#' @param group_batch_id batch ID tag that was used to mark submitted jobs
#' @param namespace Kubernetes namespace to search for jobs
#' @noRd
#' @return a character vector of job IDs
#'
get_k8s_job_ids_from_batch <- function(group_batch_id,
                                       namespace=getOption('abba.k8s_namespace')){

  # get list of job IDs with a given batch group
  output <- system2(command="kubectl",
                    args=c("get", "pods", "-n" , namespace, paste0("-l batch-group=", group_batch_id)),
                    stdout=TRUE, stderr=TRUE)

  # if there are no jobs with a given batch id, command will return a single string.
  # return an empty list in this case
  if (length(output)==1){return(list())}

  # remove header from output
  jobids <- utils::tail(output, 2)
  jobids_list <- sapply(jobids,
                        function(x) stringr::str_extract(x,  stringr::regex("^[\\d\\w\\-]+")),
                        USE.NAMES=FALSE)
  return(jobids_list)
}
