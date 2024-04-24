#' Extract variables created during file sourcing
#'
#' @param rproj_path path to .Rprofile or other file user wants to source before running the batch
#'
#' @return a list of variables and their values
#' @noRd
#'
read_rproj <- function(rproj_path){

  # get current directory to return to it later
  cwd <- getwd()

  # process different cases that would lead to premature return
  if (is.list(rproj_path)){return(rproj_path)}

  else if (is.null(rproj_path)){return(list())}

  # stop execution if .Rproj file does not exist
  else if (!file.exists(rproj_path)){
    stop(sprintf("Rproject file %s not found.", rproj_path))
  }

  # change working dir to that of the parent directory of target file
  setwd(dirname(rproj_path))
  # create environment that would store all variables from sourcing the target file
  rproj_env <- new.env()
  # source target file
  source(rproj_path, local=rproj_env)

  # return to original folder
  setwd(cwd)

  # return environment variables that were created during source of target file
  return(as.list(rproj_env))
}
