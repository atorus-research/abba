test_that("function errors when container information is supplied not as list", {
  expect_error(container_is_valid('1'))
})

test_that("function errors when container information does not have image attribute", {
  mount_info <- list(name='container_name')
  expect_error(container_is_valid(mount_info))
})

test_that("function errors when container information does not have name attribute", {
  mount_info <- list(image='image_name')
  expect_error(container_is_valid(mount_info))
})

test_that("Container information list is considered validated when it contains name and image attributes", {
  mount_info <- list(name='container_name', image='image_name')
  expect_equal(container_is_valid(mount_info), TRUE)
})

