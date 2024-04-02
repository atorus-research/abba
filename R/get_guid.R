#' Get numerical User ID/ Group ID on linux. By default, returns uid/gid of a current user.
#' 'user' argument can be supplied to get uid/gid of specific user
#'
#' @param user Optional; return uid/guid for a specified user, not for current user
#' @param ... other arguments that will be ignored
#'
#' @return a list of uid and gid number for user executing this function
#' @noRd
#' @examples
#' ids <- get_guid()
get_guid <- function(user='', ...){
  output <- system2("id", args=user, stdout=TRUE, stderr=TRUE)

  uid <- stringr::str_extract(output, stringr::regex("(?<=uid\\=)\\d+(?=\\()"))
  gid <- stringr::str_extract(output, stringr::regex("(?<=gid\\=)\\d+(?=\\()"))

  return(list(uid=uid, gid=gid))
}
