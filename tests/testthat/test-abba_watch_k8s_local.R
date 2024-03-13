library(mockery)

# define some expected results
status_descriptions <- list(
  Succeeded = "All containers in the Pod have terminated in success, and will not be restarted.",
  Failed = "All containers in the Pod have terminated, and at least one container has terminated in failure. That is, the container either exited with non-zero status or was terminated by the system.",
  Unknown = "For some reason the state of the Pod could not be obtained. This phase typically occurs due to an error in communicating with the node where the Pod should be running."
)

expected_jobs <- list(Unknown=list(Jobs=list(list(id='job1', path="/path/to/script1.R")), Description=status_descriptions$Unknown),
                      Failed=list(Jobs=list(list(id='job2', path="/path/to/script2.R")), Description=status_descriptions$Failed),
                      Succeeded=list(Jobs=list(list(id='job3', path="/path/to/script3.R")), Description=status_descriptions$Succeeded))

test_that("abba_watch_k8s_unit_local correctly waits and returns information about jobs", {
  mock_wait_job <- mock("job1,Pending,R -f /path/to/script1.R\njob2,Running,R -f /path/to/script2.R\njob3,Succeeded,R -f /path/to/script3.R",
                        "job1,Running,R -f /path/to/script1.R\njob2,Failed,R -f /path/to/script2.R\njob3,Succeeded,R -f /path/to/script3.R",
                        "job1,Unknown,R -f /path/to/script1.R\njob2,Failed,R -f /path/to/script2.R\njob3,Succeeded,R -f /path/to/script3.R")

  stub(abba_watch_k8s_unit_local, "system2", mock_wait_job, depth=3)
  actual <- abba_watch_k8s_unit_local('unique-job-id', unit_type='job',
                                      poll_interval_seconds = 0.1)
  expect_equal(actual, expected_jobs)
})

test_that("abba_watch_k8s_unit_local correctly waits and returns information about batch", {
  mock_wait_batch <- mock("job1,Pending,R -f /path/to/script1.R\njob2,Running,R -f /path/to/script2.R\njob3,Succeeded,R -f /path/to/script3.R",
                         "job1,Running,R -f /path/to/script1.R\njob2,Failed,R -f /path/to/script2.R\njob3,Succeeded,R -f /path/to/script3.R",
                         "job1,Unknown,R -f /path/to/script1.R\njob2,Failed,R -f /path/to/script2.R\njob3,Succeeded,R -f /path/to/script3.R")

  stub(abba_watch_k8s_unit_local, "system2", mock_wait_batch, depth=3)
  actual <- abba_watch_k8s_unit_local('unique-batch-id', unit_type='batch',
                                      poll_interval_seconds = 0.1)

  expect_equal(actual, expected_jobs)
})

test_that("abba_watch_k8s_job_local correctly returns information about jobs", {
  mock_unit <- mock('result')
  stub(abba_watch_k8s_job_local, "abba_watch_k8s_unit_local", mock_unit)
  result <- abba_watch_k8s_job_local('unique-job-id')
  expect_called(mock_unit, 1)
  expect_args(mock_unit, 1,
              unit_id='unique-job-id',
              unit_type='job',
              poll_interval_seconds = 3,
              timeout_seconds = 600,
              namespace=getOption('abba.k8s.namespace'))
})


test_that("abba_watch_k8s_batch_local correctly returns information about jobs", {
  mock_unit <- mock('result')
  stub(abba_watch_k8s_batch_local, "abba_watch_k8s_unit_local", mock_unit)
  result <- abba_watch_k8s_batch_local('unique-batch-id')
  expect_called(mock_unit, 1)
  expect_args(mock_unit, 1,
              unit_id='unique-batch-id',
              unit_type='batch',
              poll_interval_seconds = 3,
              timeout_seconds = 600,
              namespace=getOption('abba.k8s.namespace'))
})
