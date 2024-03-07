#' Save nested list representing the YAML file in specified location or in a
#' temporary directory.
#'
#' @param yaml_obj A nested list representing template YAML config
#' @param file_path Optional. Full filepath for to-be-saved YAML config
#'
#' @return Full path to the saved YAML file
#' @noRd
save_yaml <- function(yaml_obj, file_path=''){

  yaml_path <- if(file_path=='') tempfile(fileext = '.yaml') else file_path

  # a hack
  if (is.character(yaml_obj$spec$template$spec$containers[[1]]$command)){
    yaml_obj$spec$template$spec$containers[[1]]$command <-
      list(yaml_obj$spec$template$spec$containers[[1]]$command)
  }

  yaml::write_yaml(yaml_obj, yaml_path)

  return(yaml_path)
}
