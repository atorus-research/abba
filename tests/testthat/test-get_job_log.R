test_that("Supplying non-existing job id produces an error", {
  expect_error(get_k8s_job_log0("non_exst_job_id"))
})

test_that("Given a non-existing pod id, get_k8s_pod_log0 produces an error", {
  expect_error(get_k8s_pod_log0("non-existing-pod-id-2135"))
})

test_that("Supplying more than 1 job id returns a list with amount of elements equal to amount of supplied job ids", {
  m <- mock('job 1 log line 1', 'job 2 log line 1')
  stub(abba_get_k8s_job_log_local, 'system2', m, depth=2)
  log <- abba_get_k8s_job_log_local(c("job_id1", "job_id2"))
  expect_equal(length(log), 2L)
})

test_that("Given a non-existing batch id, get_batch_log returns an empty list", {
  expect_error(abba_get_k8s_batch_log_local("non-existing-batch-id-2135"))
})

test_that("get_k8s_pod_log0 returns log for an existing pod", {
  m <- mock(c('log line 1', 'log line 2'))
  stub(get_k8s_pod_log0, 'system2', m)
  log <- get_k8s_pod_log0("unique_pod_id")
  expected <- list(pod_id="unique_pod_id", log=c('log line 1', 'log line 2'))
  expect_equal(log, expected)
})
