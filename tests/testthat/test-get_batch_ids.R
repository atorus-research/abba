test_that("get_batch_ids returns an empty list if no jobs exist with a given batch id", {
  expect_equal(get_batch_ids('non-existing-batch-id-945387'), list())
})
