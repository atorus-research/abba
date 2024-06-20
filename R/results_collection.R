# simple function to create a data frame with results
# WORKS ONLY FOR BATCHES SUBMITTED TO WORKBENCH FOR NOW
compose_batch_results <- function(job_ids=NULL,
                                  prog_names=NULL,
                                  status_func=rslauncher_get_job_display_status,
                                  ...){
  # all components must be specified
  if (is.null(job_ids) & is.null(prog_names)){
    warning("Job IDs and program names were not provided. Batch results will not be composed.")
    return(stats::setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("job_ID", "program_name", "status")))
  }
  if (is.null(status_func)){
    warning("status function was not provided. Batch results will not be composed.")
    return(stats::setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("job_ID", "program_name", "status")))
  }

  statuses <- status_func(job_ids, ...)
  names(job_ids) <- c()
  names(statuses) <- c()

  # pad vectors with NAs so that job-ids and statuses would not be repeated
  # for programs that had not been run
  max_len <- max(lengths(list(job_ids, prog_names)))
  # job_ids <- c(job_ids, rep(NA, max_len - length(job_ids)))
  # statuses <- c(statuses, rep(NA, max_len - length(statuses)))

  results <- as.data.frame(list(job_ID=rep(NA, max_len),
                                program_name=unlist(prog_names),
                                status=rep(NA, max_len)))

  for(i in 1:length(job_ids)){
    job_path <- get_program_path_by_id(job_ids[[i]])
    results[results$program_name == job_path,]$job_ID <- job_ids[[i]]
  }
  results$status <- status_func(results$job_ID)
  return(results)

}


get_id_by_program_path <- function(x){
  jobs <- rstudioapi::launcherGetJobs(tags=paste('rstudio-r-script-job', x, sep=':'))
  results <- jobs[order(sapply(jobs,'[[','submissionTime'), decreasing = TRUE)]
  return(results[[1]]$id)
}


get_program_path_by_id <- function(x){
  job_tag <- tryCatch({rstudioapi::launcherGetJob(x)$tags[[1]]},
           error=function(e){" : "}
  )

  results <- unlist(strsplit(job_tag, ":", fixed=TRUE))[[2]]
  return(results)
}
