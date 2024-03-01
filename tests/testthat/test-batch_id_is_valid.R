test_that("function errors when input is not a string", {
  expect_error(batch_id_is_valid(13435))
})

test_that("function errors when input length is bigger than 1", {
  expect_error(batch_id_is_valid(c('id1', 'id2')))
})

test_that("function returns TRUE when input is a string character of length 1", {
  expect_equal(batch_id_is_valid('id1'), TRUE)
})
