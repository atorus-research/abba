#' Load the Kubernetes job template stored in package
#'
#' @return Imported YAML as list
#' @noRd
load_yaml_template <- function() {
  yaml::read_yaml(system.file("job.yaml", package="abba"))
}


