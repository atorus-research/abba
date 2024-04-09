# detect mode for batch control
detect_batch_mode_from_input <- function(x){
  if (is.data.frame(x)){return(c('data_frame'))}
  else if (is.list(x) || is.character(x)){return(c('list'))}
  else {stop(sprintf("Expecting a data frame, character vector or a list, not %s", typeof(x)))}
}

# return unique group numbers
get_run_groups <- function(x, col_name='run_group'){
  # data frame is expected to have run_group pre-populated/pre-calculated
  if (is.data.frame(x)){
    # check if col_name is in x data frame
    if (!(col_name %in% names(x))){
      stop(sprintf("%s variable is not in input data frame. Cannot run batch if input data frame does not have run groups.", col_name))
    }
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
                              current_group=1,
                              ...){
  mode <- detect_batch_mode_from_input(x)
  # don't check anything if this is the first iteration of the loop
  if (current_group==1){return(list(prog_list=x, stop=FALSE))}

  if (mode == 'data_frame'){
    return(control_batch_flow_data_frame(x, current_group=current_group, ...))
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
                                    halt_on_error=TRUE,
                                    ...){

  result <- list(prog_list=x, stop=FALSE)

  if (!all(previous_run_ok)){
    if (halt_on_error){
      warning(sprintf("At least one of the following programs have errors in their logs:\n\t%s\nBatch execution halted.\n",
                      paste(previous_run_programs[!previous_run_ok], collapse='\n\t')))
      result$stop=TRUE
    }
    else {
      warning(sprintf("At least one of the following programs have errors in their logs:\n\t%s\n",
                      paste(previous_run_programs[!previous_run_ok], collapse='\n\t')))}
  }
  return(result)
}

# stop batch execution in 'data frame' input mode(when a data frame of programs with inputs/outputs is supplied to batch runner)
control_batch_flow_data_frame <- function(x,
                                          current_group=NULL,
                                          previous_run_programs=NULL,
                                          previous_run_ok=NULL,
                                          halt_on_error=TRUE,
                                          ...){

  result <- list(prog_list=x, stop=FALSE)

  if (!all(previous_run_ok)){
    x_filtered <- remove_failed_program_dependencies(
      x,
      failed_programs <- previous_run_programs[!previous_run_ok])

    result$prog_list <- x_filtered

    if (halt_on_error){
      warning(sprintf("At least one of the following programs have errors in their logs:\n\t%s\nPrograms that depend on failed programs will not be executed.\n",
                      paste(previous_run_programs[!previous_run_ok], collapse='\n\t')))
      result$stop=TRUE
    }
    else {
      warning(sprintf("At least one of the following programs have errors in their logs:\n\t%s\n",
                      paste(previous_run_programs[!previous_run_ok], collapse='\n\t')))
    }
  }
  return(result)
}

# filter list/dataset to select programs for submission
select_parallel_run <- function(x, run_group, col_name='run_group'){
  mode <- detect_batch_mode_from_input(x)
  # data frame is expected to have run_group pre-populated/pre-calculated
  if (mode=='data_frame'){
    return(x[x[[col_name]]==run_group,]$program_name)
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

  # iteratively find all dependents of failed programs
  for (rg in c(all_groups[failed_programs_group:length(all_groups)])){

    current_failed_programs <- calculate_next_dependencies(
      x_filtered,
      current_group=rg,
      failed_programs=current_failed_programs,
      col_name=col_name)

    failed_programs <- c(failed_programs, current_failed_programs)
  }

  # return dataset without dependents of failed programs
  return(x[!(x$program_name %in% failed_programs),])
}

#
calculate_next_dependencies <- function(x,
                                        current_group=NULL,
                                        failed_programs=NULL,
                                        col_name='run_group',
                                        ...){
  # only select programs from current group
  x_current <- x[x[[col_name]]==current_group,]
  # get outputs of all previously failed programs
  cur_group_outputs <- x[x[['program_name']] == failed_programs,]$outputs
  # next group definition: any dataset that has one or more outputs of current group
  # as its inputs
  dependents <- sapply(parse_inputs(x_current$inputs), function(y) any(y %in% cur_group_outputs))

  # if there is no next group - return empty vector
  if (all(!dependents)) {return(NULL)}

  # return program names of failed program dependents
  return(x_current[dependents,][['program_name']])

}


# remove programs from input if their inputs/program files have not changed
remove_unchanged_programs <- function(x, ...){
  mode <- detect_batch_mode_from_input(x)
  if (mode == 'data_frame'){
    return(remove_unchanged_programs_data_frame(x, ...))
  }
  else if (mode == 'list'){
    return(remove_unchanged_programs_list(x, ...))
  }
}


# recursively descend into input list and remove programs whose hash has not changed from
# the last time it was collected(usually since the last batch run)
remove_unchanged_programs_list <- function(x, ...){

  # function for recursively filtering out programs from nested list
  recursive_cache_match <- function(l){

    descend_ <-  function(x) {
      if(is.list(x)) {
        return(recursive_cache_match(x))
        }
      else if(is.character(x)) {
        return(x[!(sapply(x, function(x) cache_match(x, ...)))])
      }
      else {return(x)}
    }
    lapply(l, descend_)
  }

  x_filtered <- recursive_cache_match(x)

  # display a message about programs that were filtered out
  x_removed <- setdiff(unlist(x), unlist(x_filtered))
  if (length(x_removed) > 0){
    message(sprintf("Programs would not be re-run due to hash sum check:\n\t%s", paste(x_removed, collapse="\\n\\t")))
  }

  return(x_filtered)
}


remove_unchanged_programs_data_frame <- function(x, ...){

  # prepare a data frame
  programs_and_inputs <- x[c('program_name', 'inputs')]
  programs_and_inputs$inputs <- parse_inputs(programs_and_inputs$inputs, ...)
  # check if program cache from previous batch run matches the current program
  programs_cache_match <- apply(x, 1, function(x) lapply(unlist(x), function(x) cache_match(x, ...)))
  # remove NULL results as they are for non-existing files - we would not include
  # them when making a decision on whether to re-run this particular program
  programs_cache_match <- lapply(programs_cache_match, function(x) Filter(Negate(is.na), x))
  # only programs that have all inputs and program itself unchanged will be excluded from batch
  programs_cache_match <- sapply(programs_cache_match, function(x) all(unlist(x)))
  x_filtered <- x[!unlist(programs_cache_match),]

  # display a message about programs that were filtered out
  x_removed <- x[unlist(programs_cache_match),]$program_name
  if (length(x_removed) > 0){
    message(sprintf("Programs would not be re-run due to hash sum check:\n\t%s", paste(x_removed, collapse="\n\t")))
  }

  return(x_filtered)
}



# calculate and save program hashes for later use in batch running
update_program_hashes <- function(x, ...){
  mode <- detect_batch_mode_from_input(x)
  if (mode == 'data_frame'){
    update_program_hashes_data_frame(x, ...)
  }
  else if (mode == 'list'){
    update_program_hashes_list(x, ...)
  }
}


# function for calculating hashes for programs when input is a list
update_program_hashes_list <- function(x, ...){
  # update program hashes
  sapply(unlist(x), function(x) abba_save_file_cache(x, ...))
}


# function for calculating hashes for programs and their inputs when input is a data frame
update_program_hashes_data_frame <- function(x, ...){
  # update program hashes
  sapply(x$program_name, function(x) abba_save_file_cache(x, ...))
  # update hashes of program inputs
  sapply(unlist(parse_inputs(x$inputs)), function(x) abba_save_file_cache(x, ...))
}
