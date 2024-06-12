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
                                log_path='/tst/path/test.log',
                                rscript_path='/opt/R/421/bin/Rscript',
                                user_tag='user_tag',
                                username='test_username',
                                cpu_cores=1L,
                                memory=998,
                                job_timeout=100)

  expected <- c("#!/bin/bash",
                "#SBATCH --uid=123",
                "#SBATCH --time=100",
                "#SBATCH --cpus-per-task=1",
                "#SBATCH --mem=998",
                "#SBATCH --job-name=test-uuid-generated",
                "#SBATCH --output=/tst/path/test.log",
                "#SBATCH --chdir=/tst/path",
                "",
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


test_that("abba_slurm_get_job_status gets job status", {

  mock_system2 <- mock(c("JOBID ExitCode STATE",
                         "2955  0   COMPLETED"), cycle=TRUE)

  stub(abba_slurm_get_job_status, "system2", mock_system2, depth=2)

  actual_result <- abba_slurm_get_job_status("2955")
  expected_result <- c("COMPLETED")
  names(expected_result) <- c("2955")

  expect_equal(actual_result, expected_result)
})


test_that("abba_slurm_get_job_succeeded returns TRUE if job had 0 exit code status and FALSE otherwise", {

  mock_system2 <- mock(c("JOBID EXIT_CODE STATE", "2955  0   COMPLETED", "2971  1   COMPLETED"), cycle = TRUE)

  stub(abba_slurm_get_job_succeeded, "system2", mock_system2, depth=2)

  actual_result <- abba_slurm_get_job_succeeded(c("2955", "2971"))
  expected_result <- c(TRUE, FALSE)
  names(expected_result) <- c("2955", "2971")

  expect_equal(actual_result, expected_result)
})



test_that("abba_slurm_watch_job waits for job to finish", {
  mock_get_job_status <- mock(c('CONFIGURING','COMPLETING'),
                              c('RUNNING','COMPLETED'),
                              c('CANCELLED','COMPLETED'), loop=TRUE)
  stub(abba_slurm_watch_job,
       "abba_slurm_get_job_status",
       mock_get_job_status)

  expected_result <- c('CANCELLED','COMPLETED')

  result_actual <- abba_slurm_watch_job(c('job-id6', 'job-id7'),
                                        poll_interval_seconds = 0.1,
                                        timeout_seconds = 10)

  expect_called(mock_get_job_status, 3)
  expect_args(mock_get_job_status, 3, c('job-id6', 'job-id7'))
  expect_equal(result_actual, expected_result)
})
