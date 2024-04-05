test_that("compose_batch_results creates a data frame consisting of program names, job ids and execution statuses", {

  status_func <- mock(c('Completed', 'Completed with errors'))
  actual_results <- compose_batch_results(job_ids=c('job-id1', 'job-id2'),
                                          prog_names=c('prog1.R', 'prog2.R'),
                                          status_func=status_func)
  expected_results <- as.data.frame(list(
    job_ID=c('job-id1', 'job-id2'),
    program_name=c('prog1.R', 'prog2.R'),
    status=c('Completed', 'Completed with errors')))
  expect_equal(actual_results, expected_results)
})


test_that("compose_batch_results creates returns a NULL and produces a warning if any of input parameters is NULL", {

  status_func <- mock(c('Completed', 'Completed with errors'))

  expect_warning(actual_results <-
                   compose_batch_results(job_ids=c('job-id1', 'job-id2'),
                                         prog_names=c('prog1.R', 'prog2.R'),
                                         status_func=NULL))
  expect_null(actual_results)
})
