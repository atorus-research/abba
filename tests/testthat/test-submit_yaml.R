library(testthat)
library(mockery)

# Mock function for 'system'
mock_system <- function(command, intern = TRUE) {
  if (grepl("kubectl apply -f", command)) {
    # Simulate successful Kubernetes job submission
    return(invisible(NULL))
  }
}

# Mock function for 'yaml::read_yaml'
mock_read_yaml <- function(file_path) {
  list(metadata = list(name = "test-job-id"))
}

test_that("submit_yaml returns the correct job ID", {
  stub(submit_k8s_yaml, "system", mock_system)
  stub(submit_k8s_yaml, "yaml::read_yaml", mock_read_yaml)

  job_id <- submit_k8s_yaml("path/to/job.yaml")
  expect_equal(job_id, "test-job-id")
})
