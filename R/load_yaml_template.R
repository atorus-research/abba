#' Load the Kubernetes job template stored in package
#'
#' @return Imported YAML as list
#' @noRd
abba_load_k8s_yaml_template_local <- function() {
  yaml::read_yaml(system.file("job.yaml", package="abba"))
}


