library(testthat)

# Test for abba_get_k8s_pod_name_local function
test_that("abba_get_k8s_pod_name_local extracts pod name correctly", {
  line <- "pod1,Succeeded,/path/to/script.R"
  expect_equal(abba_get_k8s_pod_name_local(line), "pod1")
})

# Test for abba_get_k8s_pod_status_local function
test_that("abba_get_k8s_pod_status_local extracts pod status correctly", {
  line <- "pod1,Succeeded,/path/to/script.R"
  expect_equal(abba_get_k8s_pod_status_local(line), "Succeeded")
})

# Test for abba_get_k8s_pod_args_string_local function
test_that("abba_get_k8s_pod_args_string_local extracts args string correctly", {
  line <- "pod1,Succeeded,-f /path/to/script.R"
  expect_equal(abba_get_k8s_pod_args_string_local(line), "-f /path/to/script.R")
})

# Test for abba_get_k8s_pod_program_name_local function
test_that("abba_get_k8s_pod_program_name_local extracts program name correctly", {
  line <- "pod1,Succeeded,-f /path/to/script.R"
  expect_equal(abba_get_k8s_pod_program_name_local(line), "/path/to/script.R")

  line_with_additional_args <- "pod1,Succeeded,-f /path/to/script.R, extra, args"
  expect_equal(abba_get_k8s_pod_program_name_local(line_with_additional_args), "/path/to/script.R")

  line_without_program_name <- "pod1,Succeeded,-f"
  expect_equal(abba_get_k8s_pod_program_name_local(line_without_program_name), NA)
})
