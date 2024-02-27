
mount_is_valid <- function(mounts){
  # null is a default value for mount argument in configure_yaml function.
  # by default, we should not add new mounts to config
  if (is.null(mounts)){return(FALSE)}

  if (!is.list(mounts)){
    stop(paste0('Mounts should be a list, not ', typeof(mounts)))
    }
  if(!all(c('volumes', 'volumeMounts') %in% names(mounts))){
    stop(paste0('Mounts should have 2 attributes: volumes and volumeMounts, ',
                'but it instead has ', names(mounts)))
    }
  if(length(mounts$volumes) != length(mounts$volumeMounts)){
    stop(paste0('volumes and volumeMounts attributes should be equal in length.',
                'Length(volumes)=', length(mounts$volumes),', Length(volumes)=',
                length(mounts$volumeMounts)))
    }

  volumes_names <- sapply(mounts$volumes, function(x) x$name)
  volumeMounts_names <- sapply(mounts$volumeMounts, function(x) x$name)

  if(!identical(sort(volumes_names), sort(volumeMounts_names))){
    stop(paste0('Mounts should be equally named in volumes and volumeMounts. ',
                'volume names: ', volumes_names, ', volumeMounts names: ',
                volumeMounts_names))
    }

  return(TRUE)
}

container_is_valid <- function(container_info){
  # null is a default value for container argument in configure_yaml function.
  # by default, we should not change the container in config
  if (is.null(container_info)){return(FALSE)}

  if (!is.list(container_info)){
    stop(paste0('Container information should be ',
                'supplied in a list, not a ', typeof(container_info)))
    }
  if(!all(c('name', 'image') %in% names(container_info))){
    stop(paste0('Container info list should have 2 attributes: name and image, ',
                'but it instead has ', names(container_info)))
  }
  return(TRUE)
}

determine_cpu_limit <- function(cpu_limit){
  if (mcpu_to_cpu(cpu_limit) < mcpu_to_cpu(getOption('abba.lower.cpu.limit'))){
    stop(paste0('Requested amount of CPU cores(', cpu_limit, ') is below the lower limit',
                '(', getOption('abba.lower.cpu.limit'), '). '))
  }
  else if (mcpu_to_cpu(cpu_limit) > mcpu_to_cpu(getOption('abba.cpu.limit'))){
    stop(paste0('Requested CPU cores(', cpu_limit, ') exceed the upper limit',
                '(', getOption('abba.cpu.limit'), '). '))
  }
  # in case lower/upper limits were not triggered, return originally supplied cpu_limit value
  return(cpu_limit)
}

determine_memory_limit <- function(memory_limit){
  if (memory_to_bytes(memory_limit) < memory_to_bytes(getOption('abba.lower.memory.limit'))){
    stop(paste0('Requested memory(', memory_limit, ') is too low. The minimum(',
                getOption('abba.lower.memory.limit'), ') was set as limit for this job.'))
    }

  else if (memory_to_bytes(memory_limit) > memory_to_bytes(getOption('abba.memory.limit'))){
    stop(paste0('Requested memory(', memory_limit, ') exceed the limit(',
                getOption('abba.memory.limit'), '). '))
    }

  # in case lower/upper limits were not triggered, return originally supplied memory_limit value
  return(memory_limit)

}
