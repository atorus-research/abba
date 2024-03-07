test_that("function errors when input is not a string", {
  expect_error(validate_batch_id(13435))
})

test_that("function errors when input length is bigger than 1", {
  expect_error(validate_batch_id(c('id1', 'id2')))
})

test_that("function returns TRUE when input is a string character of length 1", {
  expect_equal(validate_batch_id('id1'), TRUE)
})
