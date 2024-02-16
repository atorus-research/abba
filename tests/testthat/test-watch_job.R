library(testthat)
library(mockery)

# Mock function to simulate 'system' calls to 'kubectl'
mock_system <- function(command, intern = TRUE) {
  if (grepl("kubectl get pods", command)) {
    if (grepl("some-group", command)) {
      # Simulate a scenario where one pod has succeeded and another has failed
      return("pod1,Succeeded\npod2,Failed")
    } else {
      # Default response for other groups
      return("pod1,Succeeded\npod2,Succeeded")
    }
  }
}

# Unit test for watch_job function
test_that("watch_job returns correctly for different batch groups", {
  stub(watch_job, "system", mock_system)
  
  # Test case for a batch group with a failed job
  result <- watch_job("some-group", 3, 10)
  expect_equal(result, c("pod2"))

  # Reset the stub if needed or create a new mock function for the next test case
  stub(watch_job, "system", mock_system)

  # Test case for a batch group where all jobs succeed
  result <- watch_job("other-group", 3, 10)
  expect_equal(result, "Job completed successfully")
})