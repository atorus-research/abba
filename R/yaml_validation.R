
mount_is_valid <- function(mounts){

  if (!is.list(mounts)){
    message(paste0('Mounts should be a list, not ', typeof(mounts)))
    return(FALSE)
    }
  if(!all(c('volumes', 'volumeMounts') %in% names(mounts))){
    message(paste0('Mounts should have 2 attributes: volumes and volumeMounts, ',
                   'but it instead has ', names(mounts)))
    return(FALSE)}
  if(length(mounts$volumes) != length(mounts$volumeMounts)){
    message(paste0('volumes and volumeMounts attributes should be equal in length.',
                   'Length(volumes)=', length(mounts$volumes),', Length(volumes)=',
                   length(mounts$volumeMounts)))

    return(FALSE)}

  volumes_names <- sapply(mounts$volumes, function(x) x$name)
  volumeMounts_names <- sapply(mounts$volumeMounts, function(x) x$name)
  if(!identical(sort(volumes_names), sort(volumeMounts_names))){
    message(paste0('Mounts should be equally named in volumes and volumeMounts. ',
                   'volume names: ', volumes_names, ', volumeMounts names: ',
                   volumeMounts_names))
    return(FALSE)}

  return(TRUE)
}

container_is_valid <- function(container_info){
  if (!is.list(container_info)){return(FALSE)}
  if(!all(c('name', 'image') %in% names(container_info))){
    message(paste0('Container info list should have 2 attributes: name and image, ',
                   'but it instead has ', names(container_info)))
    return(FALSE)
  }
  return(TRUE)
}

determine_cpu_limit <- function(cpu_limit){
  if (mcpu_to_cpu(cpu_limit) < mcpu_to_cpu(getOption('abba.lower.cpu.limit'))){
    message(paste0('Requested amount of CPU cores(', cpu_limit, ') is below the lower limit',
                   '(', getOption('abba.lower.cpu.limit'), '). ',
                   getOption('abba.lower.cpu.limit'), ' cores were specified as limit',
                   ' for this job.'))
    return(mcpu_to_cpu(getOption('abba.lower.cpu.limit')))
  }
  else if (mcpu_to_cpu(cpu_limit) > mcpu_to_cpu(getOption('abba.cpu.limit'))){
    message(paste0('Requested CPU cores(', cpu_limit, ') exceed the limit',
                   '(', getOption('abba.cpu.limit'), '). ',
                   getOption('abba.cpu.limit'), ' cores were specified as limit',
                   ' for this job.'))
    return(mcpu_to_cpu(getOption('abba.cpu.limit')))
  }
  # in case lower/upper limits were not triggered, return originally supplied cpu_limit value
  return(cpu_limit)
}

determine_memory_limit <- function(memory_limit){
  if (memory_to_bytes(memory_limit) < memory_to_bytes(getOption('abba.lower.memory.limit'))){
    message(paste0('Requested memory(', memory_limit, ') is too low. The minimum(',
                   getOption('abba.lower.memory.limit'), ') was set as limit for this job.'))
    return(getOption('abba.lower.memory.limit'))}

  else if (memory_to_bytes(memory_limit) > memory_to_bytes(getOption('abba.memory.limit'))){
    message(paste0('Requested memory(', memory_limit, ') exceed the limit(',
                   getOption('abba.memory.limit'), '). ', getOption('abba.memory.limit'),
                   ' units of memory were set as limit for this job.'))
    return(getOption('abba.memory.limit'))}

  # in case lower/upper limits were not triggered, return originally supplied memory_limit value
  return(memory_limit)

}
