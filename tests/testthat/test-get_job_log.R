test_that("Supplying non-existing job id returns an error message", {
  log <- get_k8s_job_log0("non_exst_job_id")
  expect_equal(log, "Job non_exst_job_id not found.")
})

test_that("Given a non-existing pod id, get_k8s_pod_log0 returns an error message", {
  log <- get_k8s_pod_log0 ("non-existing-pod-id-2135")
  expect_equal(log, "Pod non-existing-pod-id-2135 not found.")
})

test_that("Supplying more than 1 job id returns a list with amount of elements equal to amount of supplied job ids", {
  log <- abba_get_k8s_job_log_local(c("job_id1", "job_id2"))
  expect_equal(length(log), 2L)
})

test_that("Given a non-existing batch id, get_batch_log returns an empty list", {
  log <- abba_get_k8s_batch_log_local("non-existing-batch-id-2135")
  expect_equal(log, list())
})

test_that("get_k8s_pod_log0 returns log for an existing pod", {
  m <- mock(c('log line 1', 'log line 2'))
  stub(get_k8s_pod_log0, 'system2', m)
  log <- get_k8s_pod_log0("unique_pod_id")
  expected <- list(pod_id="unique_pod_id", log=c('log line 1', 'log line 2'))
  expect_equal(log, expected)
})
