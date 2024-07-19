library(mockery)

test_that("detect_batch_mode_from_input correctly detects type of input", {
  expect_equal(detect_batch_mode_from_input(list()), 'list')
  expect_equal(detect_batch_mode_from_input(c('1')), 'list')
  expect_equal(detect_batch_mode_from_input(as.data.frame(list())), 'data_frame')
})


test_that("detect_batch_mode_from_input errors when input is not character vector/list/data frame", {
  expect_error(detect_batch_mode_from_input(NULL))
})


test_that("get_run_groups returns unique values of run group variable", {
  df_input <- as.data.frame(list(run_group=c(1,1,1,1,2,2,3,3,3,3)))
  expect_equal(get_run_groups(df_input),  c(1,2,3))

  list_input <- list(c('prog1.R', 'prog2.R'),
                     c('prog3.R'),
                     c('Prog4.R', 'prog5.R'),
                     c('Prog6.R'))
  expect_equal(get_run_groups(list_input),  c(1,2,3,4))

  expect_equal(get_run_groups(c('prog1.R', 'prog2.R')),  c(1,2))
})


test_that("get_run_groups errors when input data frame does not contain col_name variable", {
  df_input <- as.data.frame(list(run_group=c(1,1,1,1,2,2,3,3,3,3)))
  expect_error(get_run_groups(df_input, col_name='rg'))
})


test_that("batch_run_control returns unmodified input when current_group equals to 1", {
  mock_control_flow_df <- mock("data_frame_flow")
  mock_control_flow_list <- mock("list_flow")
  stub(batch_run_control, "control_batch_flow_data_frame", mock_control_flow_df)
  stub(batch_run_control, "control_batch_flow_list", mock_control_flow_list)

  actual_result <- batch_run_control(as.data.frame(list()),
                                     current_group=1,
                                     arg3='arg3')
  expect_called(mock_control_flow_df, 0)
  expect_called(mock_control_flow_list, 0)

  expect_equal(actual_result, list(prog_list=as.data.frame(list()), stop=FALSE))
})


test_that("batch_run_control runs as expected when input is a data frame", {
  mock_control_flow_df <- mock("data_frame_flow")
  mock_control_flow_list <- mock("list_flow")
  stub(batch_run_control, "control_batch_flow_data_frame", mock_control_flow_df)
  stub(batch_run_control, "control_batch_flow_list", mock_control_flow_list)

  actual_result <- batch_run_control(as.data.frame(list()),
                                     current_group=2,
                                     arg3='arg3')
  expect_called(mock_control_flow_df, 1)
  expect_called(mock_control_flow_list, 0)

  expect_args(mock_control_flow_df, 1,
              as.data.frame(list()), current_group=2, arg3='arg3')
})


test_that("batch_run_control runs as expected when input is a list", {
  mock_control_flow_df <- mock("data_frame_flow")
  mock_control_flow_list <- mock("list_flow")
  stub(batch_run_control, "control_batch_flow_data_frame", mock_control_flow_df)
  stub(batch_run_control, "control_batch_flow_list", mock_control_flow_list)

  actual_result <- batch_run_control(list(),
                                     current_group=2,
                                     arg3='arg3')
  expect_called(mock_control_flow_df, 0)
  expect_called(mock_control_flow_list, 1)

  expect_args(mock_control_flow_list, 1,
              list(), arg3='arg3')
})


test_that("control_batch_flow_list does not halt execution if all programs from previous wave run without errors", {

  actual_result <- control_batch_flow_list(list(c('prog1.R', 'prog2.R')),
                                           previous_run_programs=c('prog1.R', 'prog2.R'),
                                           previous_run_ok=c(TRUE,TRUE))
  expected_result <- list(prog_list=list(c('prog1.R', 'prog2.R')), stop=FALSE)
  expect_equal(actual_result, expected_result)
})


test_that("control_batch_flow_list halts execution and produces warning if any programs from previous wave encountered errors during execution", {

  expect_warning(actual_result <- control_batch_flow_list(list(c('prog1.R', 'prog2.R')),
                                                          previous_run_programs=c('prog1.R', 'prog2.R'),
                                                          previous_run_ok=c(TRUE,FALSE)))
  expected_result <- list(prog_list=list(c('prog1.R', 'prog2.R')), stop=TRUE)
  expect_equal(actual_result, expected_result)
})


test_that("control_batch_flow_list does not halt execution but produces warning if halt_on_error is set to FALSE", {

  expect_warning(actual_result <- control_batch_flow_list(list(c('prog1.R', 'prog2.R')),
                                                          previous_run_programs=c('prog1.R', 'prog2.R'),
                                                          previous_run_ok=c(TRUE,FALSE),
                                                          halt_on_error=FALSE))
  expected_result <- list(prog_list=list(c('prog1.R', 'prog2.R')), stop=FALSE)
  expect_equal(actual_result, expected_result)
})


test_that("control_batch_flow_data_frame does not halt execution if all programs from previous wave ran without errors", {
  df <- as.data.frame(list(program=c('prog1.R', 'prog2.R', 'prog3.R', 'prog4.R', 'prog5.R'),
                           inputs=c('raw.dm', 'sdtm.dm,raw.ae', 'sdtm.dm', 'sdtm.ae', 'sdtm.dm,sdtm.ae'),
                           outputs=c('sdtm.dm', 'sdtm.ae', 'tlf.dm', 'tlf.ae', 'tlf.sp'),
                           run_group=c(1,2,3,3,3)))

  actual_result <- control_batch_flow_data_frame(
    df,
    previous_run_programs=c('prog1.R', 'prog2.R'),
    previous_run_ok=c(TRUE,TRUE))

  expected_result <- list(prog_list=df, stop=FALSE)
  expect_equal(actual_result, expected_result)
})


test_that("control_batch_flow_data_frame halts execution and returns filtered data frame if any programs from previous wave ran without errors", {
  mock_remove_failed_program_dependencies <- mock("df_filtered")
  stub(control_batch_flow_data_frame,
       "remove_failed_program_dependencies",
       mock_remove_failed_program_dependencies)

  expect_warning(actual_result <- control_batch_flow_data_frame(
    df,
    previous_run_programs=c('prog1.R', 'prog2.R'),
    previous_run_ok=c(TRUE,FALSE)))

  expected_result <- list(prog_list="df_filtered", stop=TRUE)
  expect_equal(actual_result, expected_result)
})


test_that("control_batch_flow_data_frame does not halt execution and returns filtered data frame if any programs from previous wave ran without errors and halt_on_error is FALSE", {
  mock_remove_failed_program_dependencies <- mock("df_filtered")
  stub(control_batch_flow_data_frame,
       "remove_failed_program_dependencies",
       mock_remove_failed_program_dependencies)

  expect_warning(actual_result <- control_batch_flow_data_frame(
    df,
    previous_run_programs=c('prog1.R', 'prog2.R'),
    previous_run_ok=c(TRUE,FALSE),
    halt_on_error=FALSE))

  expected_result <- list(prog_list="df_filtered", stop=FALSE)
  expect_equal(actual_result, expected_result)
})


test_that("select_parallel_run correctly filters data frame", {
  df <- as.data.frame(list(program_name=c('prog1.R', 'prog2.R', 'prog3.R', 'prog4.R', 'prog5.R'),
                           inputs=c('raw.dm', 'sdtm.dm,raw.ae', 'sdtm.dm', 'sdtm.ae', 'sdtm.dm,sdtm.ae'),
                           outputs=c('sdtm.dm', 'sdtm.ae', 'tlf.dm', 'tlf.ae', 'tlf.sp'),
                           run_group=c(1,2,3,3,3)))

  actual_result <- select_parallel_run (df, 2, col_name='run_group')

  expected_result <- df[2,]$program_name
  expect_equal(actual_result, expected_result)
})


test_that("select_parallel_run correctly filters list", {
  l_input <- list(c('prog1.R'), c('prog2.R'), c('prog3.R', 'prog4.R', 'prog5.R'))

  actual_result <- select_parallel_run (l_input, 3)

  expected_result <- unlist(l_input[[3]])
  expect_equal(actual_result, expected_result)
})


test_that("calculate_next_dependencies returns empty vector if the current group is the last one", {
  df <- as.data.frame(list(program_name=c('prog1.R', 'prog2.R', 'prog3.R', 'prog4.R', 'prog5.R'),
                           inputs=c('raw.dm', 'sdtm.dm,raw.ae', 'sdtm.dm', 'sdtm.ae', 'sdtm.dm,sdtm.ae'),
                           outputs=c('sdtm.dm', 'sdtm.ae', 'tlf.dm', 'tlf.ae', 'tlf.sp'),
                           run_group=c(1,2,3,3,3)))

  result_actual <- calculate_next_dependencies(df, current_group=3,
                                               failed_programs=c('prog5.R'))
  expected_result <- NULL

  expect_equal(result_actual, expected_result)
})

test_that("calculate_next_dependencies properly returns programs that depend on failed programs", {
  df <- as.data.frame(list(program_name=c('prog1.R', 'prog2.R', 'prog3.R', 'prog4.R', 'prog5.R'),
                           inputs=c('raw.dm', 'sdtm.dm,raw.ae', 'sdtm.dm', 'sdtm.ae', 'sdtm.dm,sdtm.ae'),
                           outputs=c('sdtm.dm', 'sdtm.ae', 'tlf.dm', 'tlf.ae', 'tlf.sp'),
                           run_group=c(1,2,3,3,3)))

  result_actual <- calculate_next_dependencies(df, current_group=3,
                                               failed_programs=c('prog2.R'))
  expected_result <- c('prog4.R', 'prog5.R')

  expect_equal(result_actual, expected_result)
})


test_that("remove_failed_program_dependencies properly filters input dataset from programs that depend on failed programs", {
  df <- as.data.frame(list(program_name=c('prog1.R', 'prog2.R', 'prog3.R', 'prog4.R', 'prog5.R', 'prog6.R', 'prog7.R', 'prog8.R', 'prog9.R'),
                           inputs=c('raw.dm', 'raw.ds', 'raw.ae', 'sdtm.dm,sdtm.ds', 'sdtm.ae', 'adam.adsl,sdtm.ds', 'adam.adsl', 'adam.adds', 'adam.adae'),
                           outputs=c('sdtm.dm', 'sdtm.ds', 'sdtm.ae', 'adam.adsl', 'adam.adae', 'adam.adds', 'tlf.dm', 'tlf.ds', 'tlf.ae'),
                           run_group=c(1,1,1,2,2,3,4,4, 4)))

  result_actual <- remove_failed_program_dependencies (df, c('prog2.R'))
  expected_result <- df[c(1,3,5,7,9),]

  expect_equal(result_actual, expected_result)
})


test_that("remove_failed_program_dependencies returns dataset unchanged if failed programs are in the last run_group", {
  df <- as.data.frame(list(program_name=c('prog1.R', 'prog2.R', 'prog3.R', 'prog4.R', 'prog5.R', 'prog6.R', 'prog7.R', 'prog8.R', 'prog9.R'),
                           inputs=c('raw.dm', 'raw.ds', 'raw.ae', 'sdtm.dm,sdtm.ds', 'sdtm.ae', 'adam.adsl,sdtm.ds', 'adam.adsl', 'adam.adds', 'adam.adae'),
                           outputs=c('sdtm.dm', 'sdtm.ds', 'sdtm.ae', 'adam.adsl', 'adam.adae', 'adam.adds', 'tlf.dm', 'tlf.ds', 'tlf.ae'),
                           run_group=c(1,1,1,2,2,3,4,4, 4)))

  result_actual <- remove_failed_program_dependencies (df, c('prog7.R'))
  expected_result <- df

  expect_equal(result_actual, expected_result)
})
