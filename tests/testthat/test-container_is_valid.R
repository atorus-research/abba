test_that("function errors when container information is supplied not as list", {
  expect_error(abba_validate_k8s_container('1'))
})

test_that("function returns FALSE when the input argument is NULL", {
  expect_equal(abba_validate_k8s_container(NULL), FALSE)
})

test_that("function returns FALSE when the input argument is an empty string", {
  expect_equal(abba_validate_k8s_container(''), FALSE)
})

test_that("function errors when container information does not have image attribute", {
  mount_info <- list(name='container_name')
  expect_error(abba_validate_k8s_container(mount_info))
})

test_that("function errors when container information does not have name attribute", {
  mount_info <- list(image='image_name')
  expect_error(abba_validate_k8s_container(mount_info))
})

test_that("Container information list is considered validated when it contains name and image attributes", {
  mount_info <- list(name='container_name', image='image_name')
  expect_equal(abba_validate_k8s_container(mount_info), TRUE)
})

