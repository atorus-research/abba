test_that("compose_batch_results creates a data frame consisting of program names, job ids and execution statuses", {

  status_func <- mock(c('Completed', 'Completed with errors'), cycle=TRUE)
  get_job_path_by_id_func <- mock('/path/to/prog1.R', '/path/to/prog2.R')

  stub(compose_batch_results, "get_program_path_by_id", get_job_path_by_id_func)

  actual_results <- compose_batch_results(job_ids=c('job-id1', 'job-id2'),
                                          prog_names=c('/path/to/prog1.R', '/path/to/prog2.R'),
                                          status_func=status_func)
  expected_results <- as.data.frame(list(
    job_ID=c('job-id1', 'job-id2'),
    program_name=c('/path/to/prog1.R', '/path/to/prog2.R'),
    status=c('Completed', 'Completed with errors')))
  expect_equal(actual_results, expected_results)
})


test_that("compose_batch_results creates returns a NULL and produces a warning if any of input parameters is NULL", {

  status_func <- mock(c('Completed', 'Completed with errors'))
  get_job_path_by_id_func <- mock('/path/to/prog1.R', '/path/to/prog2.R')

  stub(compose_batch_results, "get_program_path_by_id", get_job_path_by_id_func)

  expect_warning(actual_result <-
                   compose_batch_results(job_ids=c('job-id1', 'job-id2'),
                                         prog_names=c('/path/to/prog1.R', '/path/to/prog2.R'),
                                         status_func=NULL))
  expected_result <- setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("job_ID", "program_name", "status"))

  expect_equal(actual_result, expected_result)
})
