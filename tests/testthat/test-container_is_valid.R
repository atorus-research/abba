test_that("Checks pass if no option is set", {
  op <- options(abba.permitted.containers = NULL)

  expect_silent(validate_k8s_container("bad_name"))

  options(op)
})

test_that("Error generates properly when container name is invalid", {
  permitted_containers <- c("path.io/container-1.0.0", "path.io/container2-1.0.0", "path.io/container3-1.0.0")

  op <- options(abba.permitted.containers = permitted_containers)

  expect_snapshot_error(validate_k8s_container("bad_name"))

  options(op)
})

test_that("Check passes properly when container name is valid", {
  permitted_containers <- c("path.io/container-1.0.0", "path.io/container2-1.0.0", "path.io/container3-1.0.0")

  op <- options(abba.permitted.containers = permitted_containers)

  expect_silent(validate_k8s_container("path.io/container-1.0.0"))

  options(op)
})
