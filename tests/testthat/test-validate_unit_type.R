test_that("function returns TRUE when unit_type equals to 'job' or 'batch'", {
  expect_equal(TRUE, validate_unit_type('job'))
  expect_equal(TRUE, validate_unit_type('batch'))
})

test_that("function errors out when unit_type is not a character", {
  expect_error(validate_unit_type(1))
})

test_that("function errors out when unit_type is not one of 'job', 'batch'", {
  expect_error(validate_unit_type('not a job'))
})
