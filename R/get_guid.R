#' Get numerical User ID/ Group ID on linux
#'
#' @return a list of uid and gid number for user executing this function
#' @noRd
#' @examples
#' ids <- abba_get_guid_local()
abba_get_guid_local <- function(){
  output <- system("id", intern=TRUE)

  uid <- stringr::str_extract(output, stringr::regex("(?<=uid\\=)\\d+(?=\\()"))
  gid <- stringr::str_extract(output, stringr::regex("(?<=gid\\=)\\d+(?=\\()"))

  return(list(uid=uid, gid=gid))
}
