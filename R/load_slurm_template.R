#' Load the Slurm job template stored in package
#'
#' @return Imported bash script as a list of strings
#' @noRd
load_slurm_template <- function() {
  readLines(system.file("slurm_job.submit", package="abba"))
}


