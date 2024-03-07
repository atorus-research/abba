#' Create a Batch API file template
#'
#' This function create a batch API file template as the specified location. The
#' Batch API file template is a plumber API with the necessary REST API methods
#' to interface with the {abba} package. This simplifies the process of setting
#' up the receiver API for which jobs are submitted.
#'
#' @param path A file path where the API file will be created
#'
#' @return NULL
#' @export
#'
#' @examples
#'
#' \dontrun{
#' create_batch_api()
#' create_batch_api("~/api_directory")
#' create_batch_api("~/api_directory/new_api.R")
#' }
create_batch_api <- function(path=".") {

  if (grepl("\\.", path)) {
    path <- file.path(".", "plumber.R")
  }

  success <- file.copy(system.file("plumber.R", package="abba"),
                       path,
                       overwrite=FALSE)
  if(success) {
    message(sprintf("Batch API file created at %s", path.expand(path)))
  } else{
    warning(sprintf(
      "File could not be copied. Does the file %s already exist?", path
      ))
  }
  invisible()
}
