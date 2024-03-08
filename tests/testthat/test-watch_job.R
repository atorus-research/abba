library(mockery)

# Mock function to simulate 'system' calls to 'kubectl'
mock_system <- function(command, intern = TRUE) {
  if (grepl("kubectl get pods", command)) {
    if (grepl("some-group", command)) {
      # Simulate a scenario with various pod statuses including 'Unknown'
      return("pod1,Succeeded,/path/to/script1.R\npod2,Failed,/path/to/script2.R\npod3,Running,/path/to/script3.R\npod4,Pending,/path/to/script4.R\npod5,Unknown,/path/to/script5.R")
    } else {
      # Default response for other groups (all succeeded)
      return("pod1,Succeeded,R -f /path/to/script1.R\npod2,Succeeded,R -f /path/to/script2.R")
    }
  }
}

# Unit test for watch_job function
test_that("watch_job returns correctly for different batch groups", {
  # stub(watch_job, "system", mock_system)
  stub(abba_watch_k8s_job_local, "system", mock_system, depth=3)

  # Test case for a batch group with various job statuses
  result <- abba_watch_k8s_job_local("batch-group")

  # Manually define expected result
  desc_success <- "All containers in the Pod have terminated in success, and will not be restarted."

  expected_result <- list(
    Succeeded=list(
      Jobs=list(list(id='pod1', path='/path/to/script1.R'), list(id='pod2', path='/path/to/script2.R')),
      "Description"=desc_success))

  expect_equal(result, expected_result)

})
