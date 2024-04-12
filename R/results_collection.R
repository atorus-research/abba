# simple function to create a data frame with results
compose_batch_results <- function(job_ids=NULL,
                                  prog_names=NULL,
                                  status_func=rslauncher_get_job_display_status,
                                  ...){
  # all components must be specified
  if (is.null(job_ids) || is.null(prog_names) || is.null(status_func)){
    warning("Job IDs, program names or status func was not provided. Batch results will not be composed.")
    return(setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("job_ID", "program_name", "status")))
  }

  statuses <- status_func(job_ids, ...)
  names(job_ids) <- c()
  names(statuses) <- c()

  # pad vectors with NAs so that job-ids and statuses would not be repeated
  # for programs that had not been run
  max_len <- max(lengths(list(job_ids, prog_names)))
  job_ids <- c(job_ids, rep(NA, max_len - length(job_ids)))
  statuses <- c(statuses, rep(NA, max_len - length(statuses)))


  results <- as.data.frame(list(job_ID=unlist(job_ids),
                                program_name=basename(unlist(prog_names)),
                                status=statuses))
  return(results)

}
