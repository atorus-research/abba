#' Submit a job profile for execution on a Kubernetes cluster
#'
#' @param yaml_full_path Path to YAML config file
#'
#' @return Nothing
#' @export
#' @noRd
submit_yaml <- function(yaml_full_path){
  system(paste("kubectl apply -f", yaml_full_path))
}
