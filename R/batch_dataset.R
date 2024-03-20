#' Convert data frame of particular structure into a list suitable for batch submission
#' @param x A data frame. Must contain 2 columns named 'program_name' and 'run_group'
#' and have at least one record.
#' @return a list of vectors containing values from 'program_name' column. Values from
#' 'program_name' will end up in one vector if they have same value in 'run_group' column
#' @noRd
#' @examples
#' execution_list <- dataframe_to_batch_list(
#'   as.data.frame(list(program_name=c("program1.R", "program2.R", "program3.R", "program4.R", "program5.R"),
#'                      run_group=c(1, 2, 2, 3, 3))))
dataframe_to_batch_list <- function(x){

  # return a list/vector back unchanged
  if ((is.list(x) || is.character(x)) && !is.data.frame(x)){return(x)}

  # validate and process the data frame
  validate_batch_data_frame(x)

  result <- list()
  for (i in unique(x$run_group)){
    result <- c(result, list(x[x$run_group == i,]$program_name))
  }
  return(result)
}

#' Validate data frame containing information about grouping of programs for batch submission
#' @param x A data frame
#' @return TRUE if all checks pass
#' @noRd
#' @examples
#' validate_batch_data_frame(
#' as.data.frame(list(program_name=c("program1.R", "program2.R", "program3.R"),
#'                    run_group=c(1, 2, 2))))
validate_batch_data_frame <- function(x){
  if (!is.data.frame(x)){
    stop(sprintf('Batch dataset should be a data frame, not %s',
                 typeof(x)))
  }
  if (!all(c('program_name', 'run_group') %in% names(x))){
    stop(sprintf('Batch dataset should have 2 columns: program_name and run_group, but it instead has %s',
                 names(x)))}
  if (nrow(x)==0){
    stop(sprintf('Batch dataset should have at least 1 record'))
  }
  return(TRUE)
}
