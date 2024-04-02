# detect mode for batch control
detect_batch_mode_from_input <- function(x){
  if (is.data.frame(x)){return('data_frame')}
  else if (is.list(x) || is.character(x)){return('list')}
}

# return unique group numbers
get_run_groups <- function(x, col_name='run_group'){
  # data frame is expected to have run_group pre-populated/pre-calculated
  if (is.data.frame(x) && !is.null(x[[col_name]])){
    return(unique(x[[col_name]]))
  }
  # if input is a list/vector, then each element is a separate run group, therefore
  # length of list/vector is equal to amount of run groups
  else if (is.list(x) || is.character(x)){
    return(c(1:length(x)))
  }
}

# control batch execution. Function is meant to be called in a loop
batch_run_control <- function(x,
                              run_group=1,
                              ...){
  mode <- detect_batch_mode_from_input(x)

  # don't check anything if this is the first iteration of the loop
  if (run_group==1){return(x)}

  if (mode == 'data_frame'){
    return(control_batch_flow_data_frame(x, ...))
  }
  else if (mode == 'list'){
    return(control_batch_flow_list(x, ...))
  }
}

# stop batch execution in 'list' input mode(when a list of programs is supplied to batch runner)
# meant to be used in a loop, otherwise 'break' will throw an error
control_batch_flow_list <- function(x,
                                    previous_run_programs=NULL,
                                    previous_run_ok=NULL,
                                    ...){
  if (!all(previous_run_ok)){
    warning(sprintf("At least one of the following programs have errors in their logs:\n\t%s\nBatch execution halted.\n",
                    paste(previous_run_programs[!previous_run_ok], collapse='\n\t')))
    break
  }
}

# stop batch execution in 'data frame' input mode(when a data frame of programs with inputs/outputs is supplied to batch runner)
control_batch_flow_data_frame <- function(x,
                                          current_group=NULL,
                                          previous_run_programs=NULL,
                                          previous_run_ok=NULL,
                                          ...){
  if (!all(previous_run_ok)){
    x_filtered <- remove_failed_program_dependencies(
      x,
      failed_programs <- previous_run_programs[!previous_run_ok]
    )

    warning(sprintf("At least one of the following programs have errors in their logs:\n\t%s\nPrograms that depend on failed programs will not be executed.\n",
                    paste(previous_run_programs[!previous_run_ok], collapse='\n\t')))
    return(x_filtered)
  }
  return(x)
}

# filter list/dataset to select programs for submission
select_parallel_run <- function(x, run_group){
  mode <- detect_batch_mode_from_input(x)
  # data frame is expected to have run_group pre-populated/pre-calculated
  if (mode=='data_frame'){
    return(x[x$run_group==run_group,]$programs)
  }
  # in case of list/character vector, run group is just element position
  else if (mode=='list'){
    return(unlist(x[[run_group]]))
  }
}

# remove programs that depend on failed programs from data frame
remove_failed_program_dependencies <- function(x,
                                               failed_programs,
                                               col_name='run_group'){

  x_filtered <- x
  failed_programs_group <- min(x[x$program_name %in% failed_programs, ][[col_name]]) + 1

  # if failures occurred in the last run group - return dataset without modifications
  if (!(failed_programs_group %in% x[[col_name]])){return(x)}

  all_groups <- get_run_groups(x_filtered, col_name=col_name)
  current_failed_programs <- failed_programs

  print(c(all_groups[failed_programs_group:length(all_groups)]))

  # iteratively find all dependents of failed programs
  for (rg in c(all_groups[failed_programs_group:length(all_groups)])){

    current_failed_programs <- calculate_next_dependencies(
      x_filtered,
      current_group=rg,
      current_program_names=current_failed_programs,
      col_name=col_name)
    print(current_failed_programs)

    failed_programs <- c(failed_programs, current_failed_programs)
  }

  # return dataset without dependents of failed programs
  return(x[x$program_name != failed_programs,])
}

#
calculate_next_dependencies <- function(x,
                                        current_group=NULL,
                                        current_program_names=NULL,
                                        col_name='run_group',
                                        ...){
  # only select programs from current group
  x_current <- x[x[[col_name]]==current_group,]
  # get outputs of all previously failed programs
  cur_group_outputs <- x[x[['program_name']] == current_program_names,]$outputs
  # next group definition: any dataset that has one or more outputs of current group
  # as its inputs
  dependents <- sapply(parse_inputs(x_current$inputs), function(y) any(y %in% cur_group_outputs))

  # if there is no next group - return empty vector
  if (all(!dependents)) {return(NULL)}

  # return program names of failed program dependents
  return(x_current[dependents,][['program_name']])

}

