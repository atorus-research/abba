test_that("function errors when cpu limit is lower than abba.lower.cpu.limit", {
  low_value <- mcpu_to_cpu(getOption("abba.lower.cpu.limit")) * 0.5
  expect_error(validate_cpu_limit(low_value))
})

test_that("function errors when cpu limit is higher than abba.memory.limit", {
  high_value <- mcpu_to_cpu(getOption("abba.cpu.limit")) * 2
  expect_error(validate_cpu_limit(high_value))
})

test_that("function returns input value when the input argument is within limits", {
  proper_value <- mean(c(mcpu_to_cpu(getOption("abba.lower.cpu.limit")),
                         mcpu_to_cpu(getOption("abba.cpu.limit"))))
  expect_equal(validate_cpu_limit(proper_value), proper_value)
})
