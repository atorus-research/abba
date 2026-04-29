#' Create a Batch API or Job file template
#'
#' This function create a batch API or job file template at the specified
#' location. The Batch API file template is a plumber API with the necessary
#' REST API server side to interface with the \pkg{abba} package. This simplifies
#' the process of setting up the receiver API for which jobs are submitted. The
#' job template file is a markdown file with the necessary function calls to run
#' a batch job.
#'
#' Note that to deploy an R api to Posit Connect, the file must be named
#' plumber.R.
#'
#' @param path A file path where the target file will be created. Must be
#'   supplied explicitly; no default is provided so that files are never
#'   written to an unexpected location.
#'
#' @return No return value, called for side effects (file creation).
#' @rdname create_batch
#' @export
#'
#' @examples
#' # Write the template to a temporary directory
#' create_batch_api(tempdir())
#' create_batch_job(tempdir())
#'
#' \dontrun{
#' create_batch_api("~/api_directory")
#' create_batch_api("~/api_directory/plumber.R")
#'
#' create_batch_job("~/job_directory")
#' create_batch_job("~/job_directory/my_job.Rmd")
#' }
create_batch_api <- function(path) {
  create_file("plumber.R", path)
}

#' @rdname create_batch
#' @export
create_batch_job <- function(path) {
  create_file("job.Rmd", path)
}

#' Wrapper method for abba file creation
#'
#' @param src Package template to source
#' @param path Target file path
#' @noRd
create_file <- function(src = c("plumber.R", "job.Rmd"), path) {

  msg <- c("plumber.R" = "Batch API", "job.Rmd" = "Job")

  success <- file.copy(system.file(src, package="abba"),
                       path,
                       overwrite=FALSE)
  if(all(success)) {
    message(sprintf("%s file created at %s", msg[src], path.expand(path)))
  } else{
    warning(sprintf(
      "File could not be copied. Does the file %s already exist?", path
    ))
  }
  invisible()
}
