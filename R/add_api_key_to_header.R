#' Insert Connect API key into request header
#'
#' @param req request object
#' @param api_key Posit Connect API key
#'
#' @return if api_key is supplied - a modified req object with api key added to the request header
#'         if api_key is not supplied - an original, unmodified req object
#' @noRd
#' @examples
#' req <- httr2::request('base_url') %>% add_api_key_to_header(api_key=Sys.getenv("CONNECT_API_KEY"))
#'
add_api_key_to_header <- function(req, api_key=NULL){
  # throw an error at the user if api_key is not one of expected types
  if (!is.null(api_key) && !is.character(api_key)){
    stop(sprintf("api_key parameter must be a NULL or a character, not %s", typeof(api_key)))}
  # update request header if api key is supplied
  if(is.character(api_key) && nchar(api_key) > 0){
    req <- httr2::req_headers(req, Authorization = paste0("Key ", api_key))
  }
  # return the modified/unmodified request
  return(req)
}
