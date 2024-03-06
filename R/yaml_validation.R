
abba_validate_k8s_mount <- function(mounts){
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

abba_validate_k8s_container <- function(container_info){
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

abba_validate_cpu_limit <- function(cpu_limit){
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

abba_validate_memory_limit <- function(memory_limit){
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

abba_validate_batch_id <- function(batch_group_id){
  if (!is.character(batch_group_id)) {
    stop(sprintf("batch_group_id must be a string, not %s", typeof(batch_group_id)))
  }
  if (length(batch_group_id) > 1) {
    stop("batch_group_id must be a single string value")
  }
  return(TRUE)
}
