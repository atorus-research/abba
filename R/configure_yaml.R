#' Replace placeholders in imported YAML config with values supplied by user
#'
#' @param file_path Full path to R file
#' @param batch_group_id A tag to mark jobs inside one batch(i.e. SDTM, ADaM etc.)
#' @param user_tag String that describes what kind of job will be scheduled to run
#' @param cpu_limit Maximum number of cores available for Kubernetes container
#' @param memory_limit Maximum amount of RAM available for Kubernetes container
#' @param container list that contains container name and image name
#' @param mounts Specifically formatted list with information bout volumes that container would have access to during the run
#'
#' @return A nested named list, yaml_file_obj, with placeholders replaced by actual values
#' @noRd
#' @examples
#' config <- abba_configure_k8s_yaml_local(file_path="/path/to/file.R", user_tag="test program")
abba_configure_k8s_yaml_local <- function(file_path='',
                           batch_group_id='',
                           user_tag='',
                           cpu_limit= 1L,
                           memory_limit='512M',
                           container=NULL,
                           mounts=NULL,
                           username=NULL){

  yaml_file_obj <- abba_load_k8s_yaml_template_local()

  program_name <- unlist(strsplit(basename(file_path), '.', fixed = TRUE))[1]

  # By default let 'batch-group' be the lowest possible level - the program name.
  # Otherwise, keep what user has specified.
  if (is.null(batch_group_id) || batch_group_id == '') {
    batch_group_id <- program_name
  }

  # cannot have underscores in job name/generate name
  job_name <- gsub('_', '-', program_name)
  generate_name <- paste0(job_name, '-', uuid::UUIDgenerate())
  # Pull supplied username if provided, otherwise default to local user
  if (is.null(username)){
    service_user <- Sys.info()[["user"]]
  } else {
    service_user <- username
  }
  guid <- abba_get_guid_local()

  # Enforce lower and upper limits on cpu resource
  # use mcpu_to_cpu function to make sure compared values have equal units
  cpu_limit <- abba_validate_cpu_limit(cpu_limit)

  # Enforce lower and upper limits on memory
  # use memory_to_bytes function to make sure compared values have equal units
  memory_limit <- abba_validate_memory_limit(memory_limit)

  # update container info in configuration file
  yaml_file_obj <- abba_update_k8s_container_local(yaml_file_obj, container)

  # add specified mounts to configuration file
  yaml_file_obj <- abba_update_k8s_mounts_local(yaml_file_obj, mounts)

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

#' Update mounts information in yaml config. Mounts information should follow
#' specific format: it has to be a list with 2 attributes, volumes and volumeMounts.
#' The yaml object will not be updated if mounts object fails validation. Validation
#' is carried out by mount.is.valid function.
#' Example of proper mounts object:
#' mounts=list(volumes=list(list(name='mount1',
#'                               nfs=list(server='0.0.0.0', path='/mnt/mount1'))),
#'             volumeMounts=list(list(name='mount1', mountPath='/mnt/mount1')))
#'
#' @param yaml yaml file representation in a form of nested list
#' @param mounts list that contains information about volumes that user wants to mount.
#'
#' @return updated
#' @noRd
#'
#' @examples \dontrun{
#' yaml <- abba_update_k8s_mounts_local(yaml,
#'                       list(volumes=list(list(name='mount1',
#'                                              nfs=list(server='0.0.0.0',
#'                                                       path='/mnt/mount1'))),
#'                            volumeMounts=list(list(name='mount1',
#'                                                   mountPath='/mnt/mount1'))))}
abba_update_k8s_mounts_local <- function(yaml, mounts){

  # validate mounts
  if (!abba_validate_k8s_mount(mounts)){return(yaml)}

  # update the fields in yaml after all checks are successful
  yaml$spec$template$spec$volumes <- c(yaml$spec$template$spec$volumes, mounts$volumes)

  yaml$spec$template$spec$containers[[1]]$volumeMounts <-
    c(yaml$spec$template$spec$containers[[1]]$volumeMounts, mounts$volumeMounts)

  return(yaml)
}

#' Update container information in yaml configuration object
#'
#' @param yaml yaml file representation in a form of nested list
#' @param container_info list that contains information about container that user wants to use.
#'
#' @return updated yaml object
#' @noRd
#'
#' @examples \dontrun{
#' yaml <- abba_update_k8s_container_local(yaml,
#'                          list(name='rs-launcher-container',
#'                               image='atoruscontainers.azurecr.io/jammy-1.0.1-workbench'))}
abba_update_k8s_container_local <- function(yaml, container_info){
  # return unmodified yaml if supplied container information is not correctly specified
  if(!abba_validate_k8s_container(container_info)){return(yaml)}
  # update the fields for ONE(first) container
  yaml$spec$template$spec$containers[[1]]$name <- container_info$name
  yaml$spec$template$spec$containers[[1]]$image <- container_info$image
  return(yaml)
}

