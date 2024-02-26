test_that("Container information can only be supplied in a list type", {
  expect_equal(container_is_valid('1'), FALSE)
})

test_that("Container information should contain name and image attributes", {
  mount_info <- list(name='container_name')
  expect_equal(container_is_valid(mount_info), FALSE)
})

test_that("Container information should contain name and image attributes - 2", {
  mount_info <- list(image='image_name')
  expect_equal(container_is_valid(mount_info), FALSE)
})

test_that("Container information list is considered validated when it contains name and image attributes", {
  mount_info <- list(name='container_name', image='image_name')
  expect_equal(container_is_valid(mount_info), TRUE)
})

