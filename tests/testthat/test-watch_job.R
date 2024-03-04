library(mockery)

# Mock function to simulate 'system' calls to 'kubectl'
mock_system <- function(command, intern = TRUE) {
  if (grepl("kubectl get pods", command)) {
    if (grepl("some-group", command)) {
      # Simulate a scenario with various pod statuses including 'Unknown'
      return("pod1,Succeeded,/path/to/script1.R\npod2,Failed,/path/to/script2.R\npod3,Running,/path/to/script3.R\npod4,Pending,/path/to/script4.R\npod5,Unknown,/path/to/script5.R")
    } else {
      # Default response for other groups (1 success, 1 failure)
      return("pod1,Succeeded,R -f /path/to/script1.R\npod2,Failed,R -f /path/to/script2.R")
    }
  }
}

# Unit test for watch_job function
test_that("watch_job returns correctly for different batch groups", {
  # stub(watch_job, "system", mock_system)
  stub(watch_job, "system", mock_system, depth=2)

  # Test case for a batch group with various job statuses
  result <- watch_job("batch-group")

  # Manually define expected result
  expected_result <- list(Succeeded=list(
    Jobs=list(list(id='pod1', path='/path/to/script1.R'))),
    Failed=list(Jobs=list(list(id='pod2', path='/path/to/script2.R'))))


  expect_equal(result, expected_result)

})
