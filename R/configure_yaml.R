#' Replace placeholders in imported YAML config with values supplied by user
#'
#' @param yaml_file_obj A nested list representing template YAML config
#' @param file_path Full path to R file
#' @param user_tag String that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#'
#' @return A nested named list, yaml_file_obj, with placeholders replaced by actual values
#' @importFrom uuid UUIDgenerate
#' @export
#' @noRd
#' @examples
#' config <- abba::load_yaml_template()
#' config <- configure_yaml(config, file_path="/path/to/file.R", user_tag="test program")
configure_yaml <- function(yaml_file_obj,
                           file_path='',
                           user_tag='',
                           cpu_limit= 1L,
                           memory_limit='512M'){

  program_name <- unlist(strsplit(basename(file_path), '.', fixed = TRUE))[1]
  generate_name <- paste0(program_name, '-', UUIDgenerate())
  # temporary plug before figuring out where to get service user identity
  service_user <- Sys.info()[["user"]]


  # a function that would try to replace all possible keywords inside the target string
  replace_func <- function(x){
    x <- sub("JOB_NAME", program_name, x)
    x <- sub("GENERATE_NAME", generate_name, x)
    x <- sub("USER_TAG", user_tag, x)
    x <- sub("PROGRAM_FULL_PATH", file_path, x)
    x <- sub("PROGRAM_BASE_NAME", program_name, x)
    x <- sub("SERVICE_USER", service_user, x)
    x <- sub("CPU_LIMIT", as.character(cpu_limit), x)
    x <- sub("MEMORY_LIMIT", memory_limit, x)
    return(x)
  }

  # recursively walk the yaml and replace all placeholders with actual values
  recursive_replace <- function(l){
    lapply(l, function(x) if(is.list(x)) recursive_replace(x)
                          else if(is.character(x)) replace_func(x)
                          else x)
  }

  yaml_file_obj <- recursive_replace(yaml_file_obj)

  return(yaml_file_obj)

}
