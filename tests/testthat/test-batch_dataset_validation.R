test_that("function errors when batch dataset is not a data frame", {
  expect_error(validate_batch_data_frame(1))
})

test_that("function errors when the input data frame does not have required columns", {
  expect_error(validate_batch_data_frame(as.data.frame(test=c(1, 2))))
})

test_that("function errors when input dataframe is empty", {
  expect_error(validate_batch_data_frame(as.data.frame(program_name=c(), run_group=c())))
})
