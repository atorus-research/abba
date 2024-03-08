test_that("Supplying non-existing job id returns an error message", {
  log <- get_k8s_job_log0("non_exst_job_id")
  expect_equal(log, "Job non_exst_job_id not found.")
})

test_that("Supplying more than 1 job id returns a list with amount of elements equal to amount of supplied job ids", {
  log <- abba_get_k8s_job_log_local(c("job_id1", "job_id2"))
  expect_equal(length(log), 2L)
})

test_that("Given a non-existing batch id, get_batch_log returns an empty list", {
  log <- abba_get_k8s_batch_log_local("non-existing-batch-id-2135")
  expect_equal(log, list())
})
