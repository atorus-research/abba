library(testthat)
library(mockery)

# Mock function to simulate 'system' calls to 'kubectl'
mock_system <- function(command, intern = TRUE) {
  if (grepl("kubectl get pods", command)) {
    if (grepl("some-group", command)) {
      # Simulate a scenario with various pod statuses including 'Unknown'
      return("pod1,Succeeded,/path/to/script1.R\npod2,Failed,/path/to/script2.R\npod3,Running,/path/to/script3.R\npod4,Pending,/path/to/script4.R\npod5,Unknown,/path/to/script5.R")
    } else {
      # Default response for other groups (all succeeded)
      return("pod1,Succeeded,/path/to/script1.R\npod2,Succeeded,/path/to/script2.R")
    }
  }
}

# Unit test for watch_job function
test_that("watch_job returns correctly for different batch groups", {
  stub(watch_job, "system", mock_system)
  
  # Test case for a batch group with various job statuses
  result <- watch_job("some-group")
  
  # Manually process the mocked output to create the expected result
  mocked_output <- mock_system("kubectl get pods -n rstudio -l batch-group=some-group -o=jsonpath=...")
  expected_result <- list()
  for (line in unlist(strsplit(mocked_output, "\n"))) {
    if (line != "") {
      status <- get_pod_status(line)
      name <- get_pod_name(line)
      program <- get_pod_program_name(line)
      expected_result[[status]] <- c(expected_result[[status]], list(name, program))
    }
  }
  
  expect_equal(result, expected_result)

})
