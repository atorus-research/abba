#' Checks that mount information is supplied in expected format
#'
#' @param mounts a named list representing k8s mount information
#'
#' @return TRUE if mounts structure is as expected
#' @noRd
#'
validate_k8s_mount <- function(mounts){
  # null is a default value for mount argument in configure_yaml function.
  # by default, we should not add new mounts to config
  if (is.null(mounts) || (is.character(mounts) && mounts == '')){return(FALSE)}

  if (!is.list(mounts)){
    stop(sprintf('Mounts should be a list, not %s',
                 typeof(mounts)))}
  if(!all(c('volumes', 'volumeMounts') %in% names(mounts))){
    stop(sprintf('Mounts should have 2 attributes: volumes and volumeMounts, but it instead has %s',
                 names(mounts)))}
  if(length(mounts$volumes) != length(mounts$volumeMounts)){
    stop(sprintf('volumes and volumeMounts attributes should be equal in length. Length(volumes)=%d, Length(volumeMounts)=%d',
                 length(mounts$volumes), length(mounts$volumeMounts)))
  }

  volumes_names <- sapply(mounts$volumes, function(x) x$name)
  volumeMounts_names <- sapply(mounts$volumeMounts, function(x) x$name)

  if(!identical(sort(volumes_names), sort(volumeMounts_names))){
    stop(sprintf('Mounts should be equally named in volumes and volumeMounts. Volume names: %s, volumeMounts names: %s',
                 volumes_names, volumeMounts_names))
  }

  return(TRUE)
}

#' Checks that container information is supplied in expected format
#'
#' @param container_info a named list representing k8s container information
#'
#' @return TRUE if container_infos structure is as expected
#' @noRd
#'
validate_k8s_container <- function(container_info){
  # null is a default value for container argument in configure_yaml function.
  # by default, we should not change the container in config
  if (is.null(container_info) || (is.character(container_info) && container_info == '')){
    return(FALSE)
    }

  if (!is.list(container_info)){
    stop(sprintf('Container information should be supplied in a list, not a %s.',
                 typeof(container_info)))
  }
  if(!all(c('name', 'image') %in% names(container_info))){
    stop(sprintf('Container info list should have 2 attributes: name and image, but it instead has %s.',
                 names(container_info)))
  }
  return(TRUE)
}

#' Check that cpu_limit is between lower and upper limits specified by abba package options
#'
#' @param cpu_limit amount of cores a job cannot exceed when assigning resources
#'
#' @return TRUE if cpu_limit is between abba.lower.cpu.limit and abba.cpu.limit, error otherwise
#' @noRd
#'
validate_cpu_limit <- function(cpu_limit){
  if (mcpu_to_cpu(cpu_limit) < mcpu_to_cpu(getOption('abba.lower.cpu.limit'))){
    stop(sprintf('CPU limit(%s) is below the lower limit set by abba.lower.cpu.limit(%s).',
                 cpu_limit, getOption('abba.lower.cpu.limit')))
  }
  else if (mcpu_to_cpu(cpu_limit) > mcpu_to_cpu(getOption('abba.cpu.limit'))){
    stop(sprintf('CPU limit(%s) exceed the upper limit set by abba.cpu.limit(%s).',
                 cpu_limit, getOption('abba.cpu.limit')))
  }
  # in case lower/upper limits were not triggered, return originally supplied cpu_limit value
  return(cpu_limit)
}

#' Make sure memory limit is between lower and upper limit set by package options
#'
#' @param memory_limit An integer or character value specifying amount of memory
#'
#' @return TRUE if memory_limit is between lower and upper limit set by abba package options
#' @noRd
validate_memory_limit <- function(memory_limit){
  if (memory_to_bytes(memory_limit) < memory_to_bytes(getOption('abba.lower.memory.limit'))){
    stop(sprintf('Requested memory limit(%s) is lower than the minimum set by abba.lower.memory.limit(%s).',
                 memory_limit, getOption('abba.lower.memory.limit')))
  }

  else if (memory_to_bytes(memory_limit) > memory_to_bytes(getOption('abba.memory.limit'))){
    stop(sprintf('Requested memory limit(%s) exceed the limit set by abba.memory.limit(%s).',
                 memory_limit, getOption('abba.memory.limit')))
    }

  # in case lower/upper limits were not triggered, return originally supplied memory_limit value
  return(memory_limit)

}

#' Evaluate batch_id passed by user
#'
#' @param batch_group_id a string to uniquely identify a group of programs
#'
#' @return TRUE if batch_group_id passed all checks, otherwise function errors out
#' @noRd
validate_batch_id <- function(batch_group_id){
  if (!is.character(batch_group_id)) {
    stop(sprintf("batch_group_id must be a string, not %s", typeof(batch_group_id)))
  }
  if (length(batch_group_id) > 1) {
    stop("batch_group_id must be a single string value")
  }
  return(TRUE)
}

#' Evaluate unit_type
#'
#' @param unit_type a string to specify unit - either a 'job' or 'batch'
#'
#' @return TRUE if unit_type passed all checks, otherwise function errors out
#' @noRd
validate_unit_type <- function(unit_type){
  if (!is.character(unit_type)) {
    stop(sprintf("unit_type must be a string, not %s", typeof(unit_type)))
  }
  if (!(unit_type %in% c('job', 'batch'))) {
    stop(sprintf("unit_type must be one of 'job', 'batch', not %s", unit_type))
  }
  return(TRUE)
}
