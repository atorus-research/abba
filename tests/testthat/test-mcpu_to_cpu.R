test_that("Numeric values are unchanged", {
  expect_equal(mcpu_to_cpu(2.5), 2.5)
})

test_that("Numeric values are rounded up to 1e-3", {
  expect_equal(mcpu_to_cpu(0.4237), 0.424)
})

test_that("Character values without suffix are simply converted to numeric", {
  expect_equal(mcpu_to_cpu('0.500'), 0.5)
})

test_that("mcpu units are correctly converted", {
  expect_equal(mcpu_to_cpu('123m'), 0.123)
})

test_that("mcpu units are correctly converted - 2", {
  expect_equal(mcpu_to_cpu('1200m'), 1.2)
})

test_that("function errors when units other than m are supplied", {
  expect_error(mcpu_to_cpu('1200Ti'))
})
