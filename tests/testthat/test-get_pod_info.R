library(testthat)

# Test for get_pod_name function
test_that("get_pod_name extracts pod name correctly", {
  line <- "pod1,Succeeded,/path/to/script.R"
  expect_equal(get_pod_name(line), "pod1")
})

# Test for get_pod_status function
test_that("get_pod_status extracts pod status correctly", {
  line <- "pod1,Succeeded,/path/to/script.R"
  expect_equal(get_pod_status(line), "Succeeded")
})

# Test for get_pod_args_string function
test_that("get_pod_args_string extracts args string correctly", {
  line <- "pod1,Succeeded,-f /path/to/script.R"
  expect_equal(get_pod_args_string(line), "-f /path/to/script.R")
})

# Test for get_pod_program_name function
test_that("get_pod_program_name extracts program name correctly", {
  line <- "pod1,Succeeded,-f /path/to/script.R"
  expect_equal(get_pod_program_name(line), "/path/to/script.R")
  
  line_with_additional_args <- "pod1,Succeeded,-f /path/to/script.R, extra, args"
  expect_equal(get_pod_program_name(line_with_additional_args), "/path/to/script.R")
  
  line_without_program_name <- "pod1,Succeeded,-f"
  expect_equal(get_pod_program_name(line_without_program_name), NA)
})
