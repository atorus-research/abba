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

# create run_group variable using inputs and outputs of programs specified by user
calculate_run_group <- function(x, col_name='run_group_calculated'){
  x[[col_name]] <- 0
  # determine which program to run first - such program inputs are not on the outputs of any other program
  first_progs_index <- get_first_programs(x)
  x[first_progs_index,][[col_name]] <- 1
  # iteratively calculate group run order
  current_group <- 1
  while (!identical(x[[col_name]],
                    calculate_next_group(x,
                                         current_group=current_group,
                                         col_name=col_name)[[col_name]])){
    x <- calculate_next_group(x, current_group=current_group, col_name=col_name)
    current_group <- current_group + 1
  }
  return(x)
}

# split comma-separated inputs
parse_inputs <- function(x){
  return(lapply(strsplit(x, ','), stringr::str_trim))
}

# function to get indexes of programs whose inputs are not produced by any programs in the x dataset
get_first_programs <- function(x){
  return(sapply(parse_inputs(ds$inputs), function(x) all(!(x %in% ds$outputs))))
}

calculate_next_group <- function(x,
                                 current_group=1,
                                 col_name='run_group_calculated'){

  cur_group_outputs <- x[x[[col_name]] == current_group,]$outputs
  # next group definition: any dataset that has one or more outputs of current group
  # as its inputs
  next_group <- sapply(parse_inputs(x$inputs), function(y) any(y %in% cur_group_outputs))

  # if there is no next group - return unmodified dataset
  if (all(!next_group)) {return (x)}

  #
  x[next_group,][[col_name]] <- current_group + 1
  return(x)
}
