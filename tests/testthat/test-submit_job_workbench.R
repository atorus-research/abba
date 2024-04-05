library(mockery)

test_that("rslauncher_submit_job is producing an error when execution type is not 'logrx' or 'standard'", {

  expect_error(rslauncher_submit_job('/path/to/program.R', execution_type='special'))
})

test_that("rslauncher_submit_job is working as expected in 'standard' mode", {
  mock_launcher_submit_job <- mock('job-id1')
  stub(rslauncher_submit_job, "rstudioapi::launcherSubmitJob", mock_launcher_submit_job)

  result_actual <- rslauncher_submit_job('/path/to/program.R')

  expect_called(mock_launcher_submit_job, 1)

  expect_args(mock_launcher_submit_job, 1,
              args =  c("--slave", "--no-save", "--no-restore", "-f /path/to/program.R"),
              cluster = 'Local',
              command = "R",
              stdoutFile = '/path/to/program.log',
              stderrFile = '/path/to/program.log',
              name = '/path/to/program.R',
              tags = c("rstudio-r-script-job:program.R"))

  expected_result <- c('job-id1')
  # names(expected_result) <- c('/path/to/program.R')

  expect_equal(result_actual, expected_result)
})

test_that("rslauncher_submit_job accepts log_path and user_tag arguments", {
  mock_launcher_submit_job <- mock('job-id1')
  stub(rslauncher_submit_job, "rstudioapi::launcherSubmitJob", mock_launcher_submit_job)

  result_actual <- rslauncher_submit_job('/path/to/program.R',
                                         log_path='/path/to/log',
                                         user_tag='custom-user-tag')

  expect_called(mock_launcher_submit_job, 1)

  expect_args(mock_launcher_submit_job, 1,
              args =  c("--slave", "--no-save", "--no-restore", "-f /path/to/program.R"),
              cluster = 'Local',
              command = "R",
              stdoutFile = '/path/to/log/program.log',
              stderrFile = '/path/to/log/program.log',
              name = '/path/to/program.R',
              tags = c("rstudio-r-script-job:program.R", "custom-user-tag"))

  expected_result <- c('job-id1')
  # names(expected_result) <- c('/path/to/program.R')

  expect_equal(result_actual, expected_result)
})

test_that("rslauncher_submit_job is working as expected in 'logrx' mode", {
  mock_launcher_submit_job <- mock('job-id2')
  stub(rslauncher_submit_job, "rstudioapi::launcherSubmitJob", mock_launcher_submit_job)

  result_actual <- rslauncher_submit_job('/path/to/program.R', execution_type='logrx')
  expected_result <- c('job-id2')

  expect_called(mock_launcher_submit_job, 1)

  expect_args(mock_launcher_submit_job, 1,
              args =  c("--slave", "--no-save", "--no-restore",
                        sprintf("-f %s --args %s %s",
                                system.file('logrx_workbench_submission.R', package="abba"),
                                '/path/to/program.R', '/path/to/program.log')),
              cluster = 'Local',
              command = "R",
              stdoutFile = '/path/to/program.log',
              stderrFile = '/path/to/program.log',
              name = '/path/to/program.R',
              tags = c("rstudio-r-script-job:program.R"))

  expect_equal(result_actual, expected_result)
})

test_that("abba_rslauncher_submit_job_local submits job in 'standard' mode and returns job id", {
  mock_rslauncher_submit_job <- mock('job-id3')
  stub(abba_rslauncher_submit_job_local, "rslauncher_submit_job", mock_rslauncher_submit_job)

  result_actual <- abba_rslauncher_submit_job_local('/path/to/program.R',
                                                    log_path='/path/to/log',
                                                    user_tag='user_tag',
                                                    arg4='arg4')

  expected_result <- c('job-id3')

  expect_called(mock_rslauncher_submit_job, 1)
  expect_args(mock_rslauncher_submit_job, 1,
              '/path/to/program.R',
              execution_type='standard',
              log_path='/path/to/log',
              user_tag='user_tag',
              arg4='arg4')
  expect_equal(result_actual, expected_result)
})

test_that("abba_rslauncher_submit_logrx_job_local submits job in 'logrx' mode and returns job id", {
  mock_rslauncher_submit_job <- mock('job-id4')
  stub(abba_rslauncher_submit_logrx_job_local,
       "rslauncher_submit_job",
       mock_rslauncher_submit_job)

  result_actual <- abba_rslauncher_submit_logrx_job_local('/path/to/program.R',
                                                          log_path='/path/to/log',
                                                          user_tag='user_tag',
                                                          arg4='arg4')
  expected_result <- c('job-id4')

  expect_called(mock_rslauncher_submit_job, 1)
  expect_args(mock_rslauncher_submit_job, 1,
              '/path/to/program.R',
              execution_type='logrx',
              log_path='/path/to/log',
              user_tag='user_tag',
              arg4='arg4')
  expect_equal(result_actual, expected_result)
})

test_that("abba_rslauncher_get_job_status_local returns job status", {
  mock_launcherGetJob <- mock(list(status='job-status-of-job-id5'))
  stub(abba_rslauncher_get_job_status_local,
       "rstudioapi::launcherGetJob",
       mock_launcherGetJob)

  result_actual <- abba_rslauncher_get_job_status_local('job-id5')

  expected_result <- c('job-status-of-job-id5')
  names(expected_result) <- c('job-id5')

  expect_called(mock_launcherGetJob, 1)
  expect_args(mock_launcherGetJob, 1, 'job-id5')
  expect_equal(result_actual, expected_result)
})

test_that("abba_rslauncher_watch_job_local waits for job to finish", {
  mock_rslauncher_get_job_status <- mock(c('Started','In Progress'),
                                         c('In Progress','Finished'),
                                         c('Finished','Finished'), loop=TRUE)
  stub(abba_rslauncher_watch_job_local,
       "abba_rslauncher_get_job_status_local",
       mock_rslauncher_get_job_status)

  result_actual <- abba_rslauncher_watch_job_local(c('job-id6', 'job-id7'),
                                                   poll_interval_seconds = 0.1,
                                                   timeout_seconds = 10)
  expected_result <- c('job-id6', 'job-id7')

  expect_called(mock_rslauncher_get_job_status, 3)
  expect_args(mock_rslauncher_get_job_status, 3, c('job-id6', 'job-id7'))
  expect_equal(result_actual, expected_result)
})

test_that("abba_rslauncher_watch_job_local produces warning when timeout is exceeded", {
  mock_rslauncher_get_job_status <- mock(c('Started','In Progress'),
                                         c('In Progress','Finished'),
                                         c('Finished','Finished'), loop=TRUE)
  stub(abba_rslauncher_watch_job_local,
       "abba_rslauncher_get_job_status_local",
       mock_rslauncher_get_job_status)

  expect_warning(abba_rslauncher_watch_job_local(c('job-id6', 'job-id7'),
                                                 poll_interval_seconds = 0.1,
                                                 timeout_seconds = 0.1))
})


test_that("get_rslauncher_job_log0 returns job log", {
  mock_launcher_get_job <- mock(list(stdoutFile='/path/to/log/program.log'))
  mock_read_lines <- mock(c('log line 1', 'log line 2'))
  stub(get_rslauncher_job_log0, "rstudioapi::launcherGetJob",
       mock_launcher_get_job)
  stub(get_rslauncher_job_log0, "base::readLines", mock_read_lines)

  result_actual <- get_rslauncher_job_log0(c('job-id8'))
  expected_result <- c('log line 1', 'log line 2')

  expect_called(mock_launcher_get_job, 1)
  expect_args(mock_launcher_get_job, 1, c('job-id8'))
  # cannot stub readLines properly, so leaving this sealed for now
  # expect_called(mock_read_lines, 1)
  # expect_args(mock_read_lines, 1, con='/path/to/log/program.log')
  # expect_equal(result_actual, expected_result)
})


test_that("get_rslauncher_job_log0 throws an error if job does not exist", {
  expect_error(get_rslauncher_job_log0(c('nonexst-job-id')))
})


test_that("abba_rslauncher_get_job_log_local returns job logs", {
  mock_get_rslauncher_job_log0 <- mock(c('log line 1', 'log line 2'),
                                       c('log line 3', 'log line 4'))
  stub(abba_rslauncher_get_job_log_local, "get_rslauncher_job_log0",
       mock_get_rslauncher_job_log0)

  result_actual <- abba_rslauncher_get_job_log_local(c('job-id9', 'job-id10'))
  expected_result <- c('log line 1', 'log line 2')

  expect_called(mock_get_rslauncher_job_log0, 2)
  expect_args(mock_get_rslauncher_job_log0, 1, 'job-id9')
  expect_args(mock_get_rslauncher_job_log0, 2, 'job-id10')
  expect_equal(result_actual, list(c('log line 1', 'log line 2'),
                                   c('log line 3', 'log line 4')))
})


test_that("rslauncher_get_job_succeeded0 returns TRUE when job exit code is zero", {
  mock_launcherGetJob <- mock(list(exitCode=0))
  stub(rslauncher_get_job_succeeded0, "rstudioapi::launcherGetJob",
       mock_launcherGetJob)

  result_actual <- rslauncher_get_job_succeeded0(c('job-id11'))
  expected_result <- c(TRUE)

  expect_called(mock_launcherGetJob, 1)
  expect_args(mock_launcherGetJob, 1, 'job-id11')
  expect_equal(result_actual, TRUE)
})


test_that("rslauncher_get_job_succeeded0 returns FALSE when job exit code is non-zero", {
  mock_launcherGetJob <- mock(list(exitCode=1))
  stub(rslauncher_get_job_succeeded0, "rstudioapi::launcherGetJob",
       mock_launcherGetJob)

  result_actual <- rslauncher_get_job_succeeded0(c('job-id12'))
  expected_result <- c(FALSE)

  expect_called(mock_launcherGetJob, 1)
  expect_args(mock_launcherGetJob, 1, 'job-id12')
  expect_equal(result_actual, expected_result)
})


test_that("rslauncher_get_job_succeeded0 returns NULL when job is still executing", {
  mock_launcherGetJob <- mock(list())
  stub(rslauncher_get_job_succeeded0, "rstudioapi::launcherGetJob",
       mock_launcherGetJob)

  result_actual <- rslauncher_get_job_succeeded0(c('job-id13'))
  expected_result <- NULL

  expect_called(mock_launcherGetJob, 1)
  expect_args(mock_launcherGetJob, 1, 'job-id13')
  expect_equal(result_actual, expected_result)
})


test_that("abba_rslauncher_get_job_succeeded_local returns job statuses according to their exit codes", {
  mock_rslauncher_get_job_succeeded0 <- mock(TRUE, FALSE)
  stub(abba_rslauncher_get_job_succeeded_local, "rslauncher_get_job_succeeded0",
       mock_rslauncher_get_job_succeeded0)

  result_actual <- abba_rslauncher_get_job_succeeded_local(c('job-id14', 'job-id15'))
  expected_result <- c(TRUE, FALSE)
  names(expected_result) <- c('job-id14', 'job-id15')
  expect_called(mock_rslauncher_get_job_succeeded0, 2)
  expect_args(mock_rslauncher_get_job_succeeded0, 1, 'job-id14')
  expect_args(mock_rslauncher_get_job_succeeded0, 2, 'job-id15')
  expect_equal(result_actual, expected_result)
})


test_that("abba_rslauncher_get_job_succeeded_local errors when at least one job is still running", {
  mock_rslauncher_get_job_succeeded0 <- mock(TRUE, FALSE, NULL)
  stub(abba_rslauncher_get_job_succeeded_local, "rslauncher_get_job_succeeded0",
       mock_rslauncher_get_job_succeeded0)

  expect_error(abba_rslauncher_get_job_succeeded_local(c('job-id16', 'job-id17', 'job-id18')))
})


test_that("rslauncher_get_job_display_status returns job statuses according to their exit codes", {
  mock_rslauncher_get_job_succeeded0 <- mock(TRUE, FALSE)
  stub(rslauncher_get_job_display_status, "rslauncher_get_job_succeeded0",
       mock_rslauncher_get_job_succeeded0)

  result_actual <- rslauncher_get_job_display_status(c('job-id16', 'job-id17'))
  expected_result <- c('Completed', 'Completed with errors')
  names(expected_result) <- c('job-id16', 'job-id17')
  expect_called(mock_rslauncher_get_job_succeeded0, 2)
  expect_args(mock_rslauncher_get_job_succeeded0, 1, 'job-id16')
  expect_args(mock_rslauncher_get_job_succeeded0, 2, 'job-id17')
  expect_equal(result_actual, expected_result)
})


test_that("rslauncher_get_job_display_status errors when at least one job is still running", {
  mock_rslauncher_get_job_succeeded0 <- mock(TRUE, FALSE, NULL)
  stub(rslauncher_get_job_display_status, "rslauncher_get_job_succeeded0",
       mock_rslauncher_get_job_succeeded0)

  expect_error(rslauncher_get_job_display_status(c('job-id16', 'job-id17', 'job-id18')))
})
