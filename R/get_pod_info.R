#' Extract Pod Name from Line
#'
#' This function extracts the pod name from a given line of `kubectl` output.
#' Assumes each line is a comma-separated string where the first part is the pod name.
#'
#' @param line A single line of output from `kubectl`, formatted as "name,status,args".
#' @return A character string representing the name of the pod.
#' @noRd
get_k8s_pod_name <- function(line) {
  parts <- strsplit(line, ",")[[1]]
  return(parts[1])
}

#' Extract Pod Status from Line
#'
#' This function extracts the pod status from a given line of `kubectl` output.
#'
#' @param line A single line of output from `kubectl`, formatted as "name,status,args".
#' @return A character string representing the status of the pod.
#' @noRd
get_k8s_pod_status <- function(line) {
  parts <- strsplit(line, ",")[[1]]
  return(parts[2])
}

#' Extract Pod Args String from Line
#'
#' This function extracts the entire args string from a given line of `kubectl` output.
#'
#' @param line A single line of output from `kubectl`, formatted as "name,status,args".
#' @return A character string representing the args of the pod.
#' @noRd
get_k8s_pod_args_string <- function(line) {
  parts <- strsplit(line, ",")[[1]]
  return(paste(parts[-c(1,2)], collapse = ","))
}

#' Extract Pod Program Name from Line
#'
#' This function extracts the program name from the pod args in a given line of `kubectl` output.
#' It specifically looks for the pattern between '-f' and '.R'.
#'
#' @param line A single line of output from `kubectl`, formatted as "name,status,args".
#' @return A character string representing the program name used by the pod.
#' @noRd
get_k8s_pod_program_name <- function(line) {
  args_string <- get_k8s_pod_args_string(line)
  pattern <- "-f ([^,]+\\.R)"
  matches <- regmatches(args_string, regexpr(pattern, args_string))
  program_name <- ifelse(length(matches) > 0, sub(pattern, "\\1", matches), NA)
  return(program_name)
}
