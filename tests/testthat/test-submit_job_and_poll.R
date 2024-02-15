library(testthat)
library(mockery)

# Mock function for 'configure_yaml'
mock_configure_yaml <- function(...) {
  return(list())  # Return a dummy list representing the YAML configuration
}

# Mock function for 'save_yaml'
mock_save_yaml <- function(...) {
  return(tempfile())  # Return a dummy file path
}

# Mock function for 'submit_yaml'
mock_submit_yaml <- function(...) {
  return("dummy-job-id")  # Return a dummy job ID
}

# Mock function for 'watch_job'
mock_watch_job <- function(...) {
  return("Job completed successfully")  # Return a success message
}

# Mock function for 'system'
mock_system <- function(command, intern = TRUE) {
  return(invisible(NULL))  # Simulate successful execution of system commands
}

test_that("submit_job_and_poll works correctly", {
  stub(submit_job_and_poll, "configure_yaml", mock_configure_yaml)
  stub(submit_job_and_poll, "save_yaml", mock_save_yaml)
  stub(submit_job_and_poll, "submit_yaml", mock_submit_yaml)
  stub(submit_job_and_poll, "watch_job", mock_watch_job)
  stub(submit_job_and_poll, "system", mock_system)
  
  result <- submit_job_and_poll("/path/to/file.R", "test-group")
  expect_equal(result, "Job completed successfully")
})
