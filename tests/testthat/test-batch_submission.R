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
