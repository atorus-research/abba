#' Replace placeholders in imported YAML config with values supplied by user
#'
#' @param file_path Full path to R file
#' @param batch_group_id Group ID for batch processing
#' @param user_tag String that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#'
#' @return A nested named list, yaml_file_obj, with placeholders replaced by actual values
#' @export
#' @examples
#' config <- configure_yaml(file_path="/path/to/file.R", user_tag="test program")
configure_yaml <- function(file_path='',
                           batch_group_id='',
                           user_tag='',
                           cpu_limit= 1L,
                           memory_limit='512M'){

  yaml_file_obj <- abba:::load_yaml_template()
  
  program_name <- unlist(strsplit(basename(file_path), '.', fixed = TRUE))[1]
  
  # By default let 'batch-group' be the lowest possible level - the program name.
  # Otherwise, keep what user has specified.
  if (is.null(batch_group_id) || batch_group_id == '') {
    batch_group_id <- program_name
  }
  
  # cannot have underscores in job name/generate name
  job_name <- gsub('_', '-', program_name)
  generate_name <- paste0(job_name, '-', uuid::UUIDgenerate())
    # temporary plug before figuring out where to get service user identity
  service_user <- Sys.info()[["user"]]
  guid <- get_guid()

  # a function that would try to replace all possible keywords inside the target string
  replace_func <- function(x){
    x <- gsub("JOB_NAME", generate_name, x)
    x <- gsub("GENERATE_NAME", generate_name, x)
    x <- gsub("BATCH_GROUP_ID", batch_group_id, x)
    x <- gsub("USER_TAG", user_tag, x)
    x <- gsub("PROGRAM_FULL_PATH", file_path, x)
    x <- gsub("PROGRAM_BASE_NAME", program_name, x)
    x <- gsub("SERVICE_USER", service_user, x)
    x <- gsub("CPU_LIMIT", as.character(cpu_limit), x)
    x <- gsub("MEMORY_LIMIT", memory_limit, x)
    x <- gsub("RUN_AS_USER", guid$uid, x)
    x <- gsub("RUN_AS_GROUP", guid$gid, x)
    return(x)
  }

  # recursively walk the yaml and replace all placeholders with actual values
  recursive_replace <- function(l){
    lapply(l, function(x) if(is.list(x)) recursive_replace(x)
                          else if(is.character(x)) replace_func(x)
                          else x)
  }

  yaml_file_obj <- recursive_replace(yaml_file_obj)

  # convert to integer after replacement with strings
  yaml_file_obj$spec$template$spec$securityContext$runAsUser <-
    as.integer(yaml_file_obj$spec$template$spec$securityContext$runAsUser)
  yaml_file_obj$spec$template$spec$securityContext$runAsGroup <-
    as.integer(yaml_file_obj$spec$template$spec$securityContext$runAsGroup)

  return(yaml_file_obj)

}
