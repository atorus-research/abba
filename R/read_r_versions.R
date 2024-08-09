read_r_versions <- function(){

  # read data from r-versions json
  prep <- utils::read.delim("/etc/rstudio/r-versions", sep=":", header=FALSE,
                            comment.char="#", strip.white=TRUE)
  # calculate values for ID column(need for transforming data)
  id_lines <- Filter(function(x) !startsWith(x, '#'), readLines("/etc/rstudio/r-versions"))
  ids <- cumsum(id_lines == "")[id_lines!=""]

  # add ids to differentiate between information blobs belonging to different r installations
  prep$id <- ids
  # add column names
  colnames(prep) <- c("Property", "Value", "ID")

  # R installs can be specified as a list of folders without any labels
  # TODO: handle r installs that are specified as a single folder path

  # reshape data frame
  result <- as.data.frame(tidyr::pivot_wider(prep,
                                             names_from = "Property",
                                             values_from = "Value"))
  # add 'bin/R' to path
  result$Path <- sapply(result$Path, function(x) file.path(x, 'bin', 'R'))
  result$RScriptPath <- sapply(result$Path, function(x) file.path(x, 'bin', 'Rscript'))
  # remove any entries which don't actually exist
  result <- result[file.exists(result$Path),]

  return(result)
}

select_r_version <- function(r_version){
  # default to standard workbench R version if none specified by user
  if (is.null(r_version) || is.na(r_version) || r_version == ""){
    return(file.path(R.home("bin"), "R"))
  }

  # read list of r versions available for workbench
  av <- read_r_versions()
  # if label is supplied, return R executable path
  if (r_version %in% av$Label){
    return(av[av$Label == r_version,]$Path)
  }
  # if exe path is supplied, return it back if it is listed in workbench r version
  else if (r_version %in% av$Path){
    return(r_version)
  }
  # it is possible that an R version is not registered in Workbench but can still
  # be used to submit R programs
  else if (file.exists(r_version)){
    return(r_version)
  }
  else{stop(paste(
    sprintf("R version '%s' not found. Cannot submit job.", r_version),
    "List of available R versions:\n",
    paste(utils::capture.output(print(av, row.names = FALSE)), collapse="\n")))}

}

select_rscript_version <- function(r_version){
  # default to standard workbench R version if none specified by user
  if (is.null(r_version) || is.na(r_version) || r_version == ""){
    return(file.path(R.home("bin"), "Rscript"))
  }

  # read list of r versions available for workbench
  av <- read_r_versions()
  # if label is supplied, return R executable path
  if (r_version %in% av$Label){
    return(av[av$Label == r_version,]$RScriptPath)
  }
  # if exe path is supplied, return it back if it is listed in workbench r version
  else if (r_version %in% av$RScriptPath){
    return(r_version)
  }
  # it is possible that an R version is not registered in Workbench but can still
  # be used to submit R programs
  else if (file.exists(r_version)){
    return(r_version)
  }
  else{stop(paste(
    sprintf("R version '%s' not found. Cannot submit job.", r_version),
    "List of available R versions:\n",
    paste(utils::capture.output(print(av, row.names = FALSE)), collapse="\n")))}

}
