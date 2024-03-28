.onLoad <- function(libname, pkgname) {
  options(abba.lower.cpu.limit=0.001,
          abba.cpu.limit = 2,
          abba.lower.memory.limit='128M',
          abba.memory.limit='1G',
          abba.permitted.containers=NULL,
          abba.default.container=NULL,
          abba.k8s.namespace='rstudio',
          abba.home.nfs.ip.address='10.14.0.6'
  )
  invisible()
}

mcpu_to_cpu <- function(cpu){
  # don't decipher anything if cpu limit was supplied as numeric
  if (is.numeric(cpu)){
    return(round(cpu, digits=3))}

  # define conversion factor
  suffixes <- list(m=1/1000)
  # extract numerical part and suffix
  numeric_part <- gsub('[^0-9.]', '', cpu)
  suffix <- gsub('[^a-zA-Z]', '', cpu)

  # just return numeric part if no unit specified
  if (suffix==''){return(round(as.numeric(numeric_part), digits=3))}
  # return just numeric part without conversion if suffix is unrecognized
  else if (suffix != 'm'){
    stop('Unrecognized cpu unit. Allowed unis are: m')
  }
  # return converted value in CPU units
  rounded_converted <- round(as.numeric(numeric_part) * suffixes[[suffix]],
                             digits=3)
  return(rounded_converted)

}

memory_to_bytes <- function(memory){
  # don't decipher anything if memory limit was supplied as numeric
  if (! is.character(memory)){
    return(ceiling(memory))}

  # define values of conversion factors. Not going above the terabyte because
  # it is ridiculous
  suffixes <- list(k=1e3, M=1e6, G=1e9, T=1e12,
                   ki=1024, Mi=1024**2, Gi=1024**3, Ti=1024**4)
  # extract numerical part and suffix
  numeric_part <- gsub('[^0-9.]', '', memory)
  suffix <- gsub('[^a-zA-Z]', '', memory)

  # just return numeric part if no unit specified
  if (suffix==''){return(ceiling(as.numeric(numeric_part)))}
  # return just numeric part without conversion if suffix is unrecognized
  else if (!(suffix %in% names(suffixes))){
    stop('Unrecognized memory unit. Allowed units are: k, M, G, T, ki, Mi, Gi, Ti')
  }
  # return converted value in bytes
  return(ceiling(as.numeric(numeric_part) * suffixes[[suffix]]))
}
