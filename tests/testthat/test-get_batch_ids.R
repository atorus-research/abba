test_that("get_batch_ids returns an empty list if no jobs exist with a given batch id", {
  mock_system <- mock(c("NAME READY STATUS RESTARTS AGE"))

  stub(get_k8s_job_ids_from_batch, "system2", mock_system)
  expect_equal(get_k8s_job_ids_from_batch('non-existing-batch-id-945387'), list())
})


test_that("get_batch_ids correctly returns job ids when given batch id", {
  mock_system <- mock(c("NAME READY STATUS RESTARTS AGE",
                        "job-id1 0/1 Completed 0 106s",
                        "job-id2 0/1 Completed 0 99s"))

  stub(get_k8s_job_ids_from_batch, "system2", mock_system)

  expect_equal(get_k8s_job_ids_from_batch('unique-batch-id'),
               c('job-id1', 'job-id2'))
})
