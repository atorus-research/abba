library(mockery)

test_that("Package .submit file for configuring slurm job loads correctly", {
  x <- load_slurm_template()

  expect_equal(length(x), 10L)
})


test_that("Placeholders are properly updated by configure_slurm_template function", {

  mock_system2 <- mock('uid=123(test_username) gid=456(domain users)', cycle=TRUE)

  stub(configure_slurm_job, "system2", mock_system2, depth=2)
  stub(configure_slurm_job, "uuid::UUIDgenerate", "uuid-generated")

  actual <- configure_slurm_job(program_path="/tst/path/test.R",
                                log_path='',
                                rscript_path='/opt/R/421/bin/Rscript',
                                user_tag='user_tag',
                                cpu_limit=1L,
                                job_timeout=100)

  expected <- c("#!/bin/bash",
                "#SBATCH --UID=123",
                "#SBATCH --time=100",
                "#SBATCH --cpus-per-task=1",
                "#SBATCH --job-name=test-uuid-generated",
                "#SBATCH --error=/tst/path/test.log",
                "#SBATCH --output=/tst/path/test.log",
                "",
                "cd /tst/path",
                "/opt/R/421/bin/Rscript /tst/path/test.R")

  expect_equal(actual, expected)

})


test_that("save_slurm_template saves file when no file_path is specified", {
  config <- load_slurm_template()
  config_path <- save_slurm_template(config)
  expect_true(file.exists(config_path))
})

test_that("save_yaml saves file in a temporary directory when no file_path is specified", {
  config <- load_slurm_template()
  config_path <- save_slurm_template(config)
  expect_true(grepl("/tmp/", config_path, fixed=TRUE))
})


test_that("slurm_config_get_job_id correctly parses job id out of sbatch command output", {
  expect_equal(slurm_config_get_job_id('Submitted batch job 105573'), '105573')
})


test_that("submit_slurm_job_config submits script for execution", {

  mock_system2 <- mock("system2_output", cycle=TRUE)
  mock_get_job_id <- mock("job_id", cycle=TRUE)

  stub(submit_slurm_job_config, "system2", mock_system2)
  stub(submit_slurm_job_config, "slurm_config_get_job_id", mock_get_job_id)

  actual_result <- submit_slurm_job_config("/path/to/script.sh")

  expect_args(mock_system2, 1,
              command="sbatch",
              args=c("/path/to/script.sh"),
              stdout=TRUE, stderr=TRUE)

  expect_called(mock_get_job_id, 1)

  expect_equal(actual_result, "job_id")
})


test_that("slurm_get_job_status gets job status", {

  mock_system2 <- mock(c("JobID ExitCode State",
                         "----- ----- -----",
                         "2955  0   COMPLETED"), cycle=TRUE)

  stub(slurm_get_job_status, "system2", mock_system2, depth=2)

  actual_result <- slurm_get_job_status("job_id")

  expected_result <- c("COMPLETED")
  names(expected_result) <- c("job_id")

  expect_equal(actual_result, expected_result)
})

