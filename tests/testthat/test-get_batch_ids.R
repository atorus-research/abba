test_that("get_batch_ids returns an empty list if no jobs exist with a given batch id", {
  expect_equal(get_k8s_job_ids_from_batch('non-existing-batch-id-945387'), list())
})
