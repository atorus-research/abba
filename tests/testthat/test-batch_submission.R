library(mockery)

test_that("batch_submit_parallel functions as expected", {
  mock_submit <- mock('program1.R', 'program2.R')
  mock_wait <- mock('result3', 'result4')

  result_actual <- batch_submit_parallel(c('program1.R', 'program2.R'),
                                         submit_func=mock_submit,
                                         wait_func=mock_wait,
                                         arg1='arg1')
  expect_called(mock_submit, 2)
  expect_called(mock_wait, 1)

  expect_args(mock_submit, 1, 'program1.R', arg1='arg1')
  expect_args(mock_submit, 2, 'program2.R', arg1='arg1')

  expected_mock_args <- c('program1.R', 'program2.R')
  names(expected_mock_args) <- c('program1.R', 'program2.R')
  expect_args(mock_wait, 1, expected_mock_args, arg1='arg1')

  expect_equal(result_actual, expected_mock_args)
})


test_that("abba_submit_batch flattens the list if sequential=TRUE", {

  # define mock functions
  mock_dataframe_to_batch_list <- mock(list(c('prog1.R'), ('prog2.R')))
  mock_get_run_groups <- mock(c(1,2))
  mock_batch_run_control <- mock(list(prog_list=c('prog1.R'), stop=FALSE),
                                 list(prog_list=c('prog2.R'), stop=FALSE),
                                 cycle=TRUE)
  mock_select_parallel_run <- mock('prog1.R', 'prog2.R')
  mock_batch_submit_parallel <- mock('prog-id1', 'prog-id2')
  mock_submit <- mock()
  mock_wait <- mock()
  mock_abba_rslauncher_get_job_succeeded_local <- mock(TRUE, cycle=TRUE)

  # stub functions in target function
  stub(abba_submit_batch, 'dataframe_to_batch_list', mock_dataframe_to_batch_list)
  stub(abba_submit_batch, 'get_run_groups', mock_get_run_groups)
  stub(abba_submit_batch, 'batch_run_control', mock_batch_run_control)
  stub(abba_submit_batch, 'select_parallel_run', mock_select_parallel_run)
  stub(abba_submit_batch, 'batch_submit_parallel', mock_batch_submit_parallel)
  stub(abba_submit_batch, 'abba_rslauncher_get_job_succeeded_local',
       mock_abba_rslauncher_get_job_succeeded_local)

  # run the function
  result_actual <- abba_submit_batch(c('prog1.R', 'prog2.R'),
                                     sequential=TRUE,
                                     submit_func=mock_submit,
                                     wait_func=mock_wait,
                                     arg1='arg1')

  # execute checks
  expect_called(mock_dataframe_to_batch_list, 1)
  expect_called(mock_batch_submit_parallel, 2)

  expect_args(mock_batch_submit_parallel, 1,
              'prog1.R',
              submit_func=mock_submit,
              wait_func=mock_wait,
              arg1='arg1')
  expect_args(mock_batch_submit_parallel, 2,
              'prog2.R',
              submit_func=mock_submit,
              wait_func=mock_wait,
              arg1='arg1')

  expected_result <- c('prog-id1', 'prog-id2')

  expect_equal(result_actual, expected_result)
})


test_that("abba_submit_batch breaks execution cycle if programs have errors in sequential mode", {

  # define mock functions
  mock_dataframe_to_batch_list <- mock(c('prog1.R', 'prog2.R'))
  mock_get_run_groups <- mock(c(1,2))
  mock_batch_run_control <- mock(list(prog_list=c('prog1.R'), stop=FALSE),
                                 list(prog_list=c('prog2.R'), stop=TRUE),
                                 cycle=TRUE)
  mock_select_parallel_run <- mock('prog1.R', 'prog2.R')
  mock_batch_submit_parallel <- mock('prog-id1', 'prog-id2')
  mock_submit <- mock()
  mock_wait <- mock()
  mock_abba_rslauncher_get_job_succeeded_local <- mock(FALSE, cycle=TRUE)

  # stub functions in target function
  stub(abba_submit_batch, 'dataframe_to_batch_list', mock_dataframe_to_batch_list)
  stub(abba_submit_batch, 'get_run_groups', mock_get_run_groups)
  stub(abba_submit_batch, 'batch_run_control', mock_batch_run_control)
  stub(abba_submit_batch, 'select_parallel_run', mock_select_parallel_run)
  stub(abba_submit_batch, 'batch_submit_parallel', mock_batch_submit_parallel)
  stub(abba_submit_batch, 'abba_rslauncher_get_job_succeeded_local',
       mock_abba_rslauncher_get_job_succeeded_local)

  # run the function
  result_actual <- abba_submit_batch(c('prog1.R', 'prog2.R'),
                                     sequential=TRUE,
                                     halt_on_error = TRUE,
                                     submit_func=mock_submit,
                                     wait_func=mock_wait,
                                     arg1='arg1')

  # execute checks
  expect_called(mock_dataframe_to_batch_list, 1)
  expect_called(mock_batch_submit_parallel, 1)

  expect_args(mock_batch_submit_parallel, 1,
              'prog1.R',
              submit_func=mock_submit,
              wait_func=mock_wait,
              arg1='arg1')

  expected_result <- c('prog-id1')

  expect_equal(result_actual, expected_result)
})


test_that("abba_submit_batch works as expected in standard mode", {

  # define mock functions
  mock_dataframe_to_batch_list <- mock()
  mock_get_run_groups <- mock(c(1,2))
  mock_batch_run_control <- mock(list(prog_list=c('prog1.R', 'prog2.R'), stop=FALSE),
                                 list(prog_list=c('prog3.R'), stop=FALSE),
                                 cycle=TRUE)
  mock_select_parallel_run <- mock(c('prog1.R', 'prog2.R'), 'prog3.R')
  mock_batch_submit_parallel <- mock(c('prog-id1', 'prog-id2'), 'prog-id3')
  mock_submit <- mock()
  mock_wait <- mock()
  mock_abba_rslauncher_get_job_succeeded_local <- mock(TRUE, cycle=TRUE)

  # stub functions in target function
  stub(abba_submit_batch, 'dataframe_to_batch_list', mock_dataframe_to_batch_list)
  stub(abba_submit_batch, 'get_run_groups', mock_get_run_groups)
  stub(abba_submit_batch, 'batch_run_control', mock_batch_run_control)
  stub(abba_submit_batch, 'select_parallel_run', mock_select_parallel_run)
  stub(abba_submit_batch, 'batch_submit_parallel', mock_batch_submit_parallel)
  stub(abba_submit_batch, 'abba_rslauncher_get_job_succeeded_local',
       mock_abba_rslauncher_get_job_succeeded_local)

  # run the function
  result_actual <- abba_submit_batch(list(c('prog1.R', 'prog2.R'), 'prog3.R'),
                                     submit_func=mock_submit,
                                     wait_func=mock_wait,
                                     arg1='arg1')

  # execute checks
  expect_called(mock_dataframe_to_batch_list, 0)
  expect_called(mock_batch_submit_parallel, 2)

  expect_args(mock_batch_submit_parallel, 1,
              c('prog1.R','prog2.R'),
              submit_func=mock_submit,
              wait_func=mock_wait,
              arg1='arg1')
  expect_args(mock_batch_submit_parallel, 2,
              c('prog3.R'),
              submit_func=mock_submit,
              wait_func=mock_wait,
              arg1='arg1')

  expected_result <- c('prog-id1', 'prog-id2', 'prog-id3')

  expect_equal(result_actual, expected_result)
})


test_that("abba_submit_batch_and_get_results works as expected", {

  # define mock functions
  mock_abba_submit_batch <- mock('job_ids')
  mock_compose_batch_results <- mock('batch-results')
  mock_status <- mock()
  mock_submit <- mock()
  mock_wait <- mock()

  # stub functions in target function
  stub(abba_submit_batch_and_get_results, 'abba_submit_batch', mock_abba_submit_batch)
  stub(abba_submit_batch_and_get_results, 'compose_batch_results', mock_compose_batch_results)

  # run the function
  result_actual <- abba_submit_batch_and_get_results(
    list(c('prog1.R')),
    submit_func=mock_submit,
    wait_func=mock_wait,
    status_func=mock_status,
    arg1='arg1')

  # execute checks
  expect_called(mock_abba_submit_batch, 1)
  expect_called(mock_compose_batch_results, 1)

  expect_args(mock_abba_submit_batch, 1,
              list(c('prog1.R')),
              sequential=FALSE,
              submit_func=mock_submit,
              wait_func=mock_wait,
              col_name='run_group',
              halt_on_error=TRUE,
              arg1='arg1')
  expect_args(mock_compose_batch_results, 1,
              job_ids=c('job_ids'),
              prog_names=c('prog1.R'),
              status_func=mock_status)

  expected_result <- c('batch-results')

  expect_equal(result_actual, expected_result)
})
