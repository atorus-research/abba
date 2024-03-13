library(mockery)

# Mock function to simulate 'system' calls to 'kubectl'
mock_system2 <- function(command, ...) {
  args = list(...)
  if (any(sapply(args$args, function(x){grepl('unique-job-id', x, fixed=TRUE)}))){
    return("job1,Succeeded,R -f /path/to/script1.R\njob2,Failed,R -f /path/to/script2.R\njob3,Running,R -f /path/to/script3.R\njob4,Pending,R -f /path/to/script4.R\njob5,Unknown,R -f /path/to/script5.R")
  }
  else if (any(sapply(args$args, function(x){grepl('unique-batch-id', x, fixed=TRUE)}))){
    # Simulate a scenario with various pod statuses including 'Unknown'
    return("pod1,Succeeded,-R -f /path/to/script1.R\npod2,Failed,R -f /path/to/script2.R\npod3,Running,R -f /path/to/script3.R\npod4,Pending,R -f /path/to/script4.R\npod5,Unknown,R -f /path/to/script5.R")
  }
}

# define some expected results
status_descriptions <- list(
  Pending = "The Pod has been accepted by the Kubernetes cluster, but one or more of the containers has not been set up and made ready to run. This includes time a Pod spends waiting to be scheduled as well as the time spent downloading container images over the network.",
  Running = "The Pod has been bound to a node, and all of the containers have been created. At least one container is still running, or is in the process of starting or restarting.",
  Succeeded = "All containers in the Pod have terminated in success, and will not be restarted.",
  Failed = "All containers in the Pod have terminated, and at least one container has terminated in failure. That is, the container either exited with non-zero status or was terminated by the system.",
  Unknown = "For some reason the state of the Pod could not be obtained. This phase typically occurs due to an error in communicating with the node where the Pod should be running."
)

expected_jobs <- list(Succeeded=list(Jobs=list(list(id='job1', path="/path/to/script1.R")), Description=status_descriptions$Succeeded),
                      Failed=list(Jobs=list(list(id='job2', path="/path/to/script2.R")), Description=status_descriptions$Failed),
                      Running=list(Jobs=list(list(id='job3', path="/path/to/script3.R")), Description=status_descriptions$Running),
                      Pending=list(Jobs=list(list(id='job4', path="/path/to/script4.R")), Description=status_descriptions$Pending),
                      Unknown=list(Jobs=list(list(id='job5', path="/path/to/script5.R")), Description=status_descriptions$Unknown))

expected_batch <- list(Succeeded=list(Jobs=list(list(id='pod1', path="/path/to/script1.R")), Description=status_descriptions$Succeeded),
                       Failed=list( Jobs=list(list(id='pod2', path="/path/to/script2.R")), Description=status_descriptions$Failed),
                       Running=list(Jobs=list(list(id='pod3', path="/path/to/script3.R")), Description=status_descriptions$Running),
                       Pending=list(Jobs=list(list(id='pod4', path="/path/to/script4.R")), Description=status_descriptions$Pending),
                       Unknown=list(Jobs=list(list(id='pod5', path="/path/to/script5.R")), Description=status_descriptions$Unknown))

test_that("abba_get_k8s_unit_status_local correctly returns information about jobs", {
  stub(abba_get_k8s_unit_status_local, "system2", mock_system2)
  actual <- abba_get_k8s_unit_status_local('unique-job-id', unit_type='job')
  expect_equal(actual, expected_jobs)
})

test_that("abba_get_k8s_unit_status_local correctly returns information about batch", {
  stub(abba_get_k8s_unit_status_local, "system2", mock_system2)
  actual <- abba_get_k8s_unit_status_local('unique-batch-id', unit_type='batch')

  expect_equal(actual, expected_batch)
})

test_that("abba_get_k8s_job_status_local correctly returns information about jobs", {
  stub(abba_get_k8s_job_status_local, "system2", mock_system2, depth=2)
  actual <- abba_get_k8s_job_status_local('unique-job-id')
  expect_equal(actual, expected_jobs)
})

test_that("abba_get_k8s_batch_status_local correctly returns information about batch", {
  stub(abba_get_k8s_batch_status_local, "system2", mock_system2, depth=2)
  actual <- abba_get_k8s_batch_status_local('unique-batch-id')

  expect_equal(actual, expected_batch)
})
