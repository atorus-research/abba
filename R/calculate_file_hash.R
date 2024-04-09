#' Calculate and Save File's Hash Sum.
#'
#' Read in the file's contents, calculate its hash sum and save permanently
#' to the `.abba_cache` folder. Later this information could be used to decide
#' if the program needs to be re-run (due to updates make to the code).
#'
#' @param file_path A full path to the file we want to read in and generate
#' a hash sum.
#' @param cache_folder A full path to the folder containing hash sum for the input file
#' @return A hash sum of the file's contents.
#' @noRd
abba_save_file_cache <- function(file_path, cache_folder=NULL, ...) {
  hash_value <- digest::digest(file_path, algo = "md5", file = TRUE)

  # by default, put cache in .abba_cache folder inside programs folder
  if (is.null(cache_folder)){
    cache_folder <- file.path(dirname(file_path), ".abba_cache")
  }
  if (!dir.exists(cache_folder)) {
    dir.create(cache_folder)
  }

  cache_file <- file.path(cache_folder, paste0(basename(file_path), ".cache"))
  writeLines(hash_value, cache_file)

  return(hash_value)
}


#' Check the Current File's Hash Sum versus the Hash Sum for the File Generated
#' Earlier.
#'
#' This function checks if the hash of a current file matches the stored
#' hash in the cache. If not - it calls `abba_save_file_cache` to update the
#' stored hash for the file.
#'
#' @param file_path A full path to the file we want to read in and generate
#' a hash sum.
#' @param cache_folder A full path to the folder containing hash sum for the input file
#' @param update_cache Controls whether hash sum would be updated if program update is detected. TRUE by default
#' @return `NA` if file_path does not exist, `TRUE` if hash sum matches with what is stored in cache, `FALSE` otherwise.
#' @noRd
cache_match <- function(file_path, cache_folder=NULL, update_cache=TRUE, ...) {

  # produce a warning if file_path does not exist and return FALSE
  if (is.null(file_path) || !file.exists(file_path)){

    report_str <- sprintf("file_path=%s", file_path)
    if (is.null(file_path)){report_str<-sprintf("file_path=%s", 'NULL')}

    # warning(sprintf("%s does not exist. Cache would not be calculated", report_str))
    return(NA)
  }

  current_hash <- digest::digest(file_path, algo = "md5", file = TRUE)

  if (is.null(cache_folder)){
  cache_folder <- file.path(dirname(file_path), ".abba_cache")
  }
  cache_file <- file.path(cache_folder, paste0(basename(file_path), ".cache"))

  # save hash for a file and return FALSE if cash does not exist
  if (!file.exists(cache_file)) {
    if(update_cache){abba_save_file_cache(file_path)}
    return(FALSE)
  }

  # compare hashes of current program and program when it was last run in a batch
  cached_hash <- readLines(cache_file)

  if (current_hash == cached_hash) {return(TRUE)}
  else {
    if(update_cache){abba_save_file_cache(file_path)}
    return(FALSE)
    }
}
