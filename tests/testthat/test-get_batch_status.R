library(mockery)

# Mock function to simulate 'system' calls to 'kubectl'
mock_system <- function(command, intern = TRUE) {
  if (grepl("kubectl get pods", command)) {
    if (grepl("some-group", command)) {
      # Simulate a scenario with various pod statuses including 'Unknown'
      return("pod1,Succeeded,R -f /path/to/script1.R\npod2,Failed,R -f /path/to/script2.R\npod3,Running,R -f /path/to/script3.R\npod4,Pending,R -f /path/to/script4.R\npod5,Unknown,R -f /path/to/script5.R")
    } else {
      # Default response for other groups (all succeeded)
      return("pod1,Succeeded,R -f /path/to/script1.R\npod2,Succeeded,R -f /path/to/script2.R")
    }
  }
}

# Unit test for watch_job function
test_that("get_batch_status returns statuses in expected format", {
  stub(abba_get_k8s_batch_status_local, "system", mock_system)

  # Test case for a batch group with various job statuses
  result <- abba_get_k8s_batch_status_local("batch-group")

  # Manually define expected result
  desc_success <- "All containers in the Pod have terminated in success, and will not be restarted."

  expected_result <- list(
    Succeeded=list(
      Jobs=list(list(id='pod1', path='/path/to/script1.R'), list(id='pod2', path='/path/to/script2.R')),
      "Description"=desc_success))

  expect_equal(result, expected_result)

})
