#' Save nested list representing the YAML file in specified location or in a
#' temporary directory.
#'
#' @param yaml_obj A nested list representing template YAML config
#' @param file_path Optional. Full filepath for to-be-saved YAML config
#'
#' @return Full path to the saved YAML file
#' @export
#' @noRd
#' @examples
#' config <- abba::load_yaml_template()
#' config <- configure_yaml(config, file_path="/path/to/file.R", user_tag="test program")
#' config_path <- save_yaml(config)
save_yaml <- function(yaml_obj, file_path=''){

  yaml_path <- if(file_path=='') tempfile(fileext = '.yaml') else file_path

  yaml::write_yaml(yaml_obj, yaml_path)

  return(yaml_path)
}
