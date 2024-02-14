#' Submit a job profile for execution on a Kubernetes cluster
#'
#' @param yaml_full_path Path to YAML config file
#'
#' @return A string containing Job ID
#' @export
#' @noRd
submit_yaml <- function(yaml_full_path){

  # send the job for execution
  system(paste("kubectl apply -f", yaml_full_path))

  # read job id from config and return it for further tracking and reporting
  yaml_config <- yaml::read_yaml(yaml_full_path)
  return(yaml_config$metadata$name)
}
