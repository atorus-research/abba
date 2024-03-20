test_that("dataframe_to_batch_list correctly converts dataframe to batch list", {
  ds <- as.data.frame(list(program_name=c("program1.R", "program2.R", "program3.R", "program4.R", "program5.R"),
                           run_group=c(1, 2, 2, 3, 3)))
  expected <- list(c("program1.R"),
                   c("program2.R", "program3.R"),
                   c("program4.R", "program5.R"))
  actual <- dataframe_to_batch_list(ds)

  expect_equal(actual, expected)
})

test_that("dataframe_to_batch_list returns a list back unchanged", {
  expected <- list(c("program1.R"),
                   c("program2.R", "program3.R"),
                   c("program4.R", "program5.R"))
  actual <- dataframe_to_batch_list(expected)

  expect_equal(actual, expected)
})

test_that("dataframe_to_batch_list returns a character vector back unchanged", {
  expected <- c("program1.R", "program2.R", "program3.R")
  actual <- dataframe_to_batch_list(expected)

  expect_equal(actual, expected)
})


