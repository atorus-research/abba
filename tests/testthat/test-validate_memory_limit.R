test_that("function errors when memory limit is lower than abba.lower.memory.limit", {
  low_value <- memory_to_bytes(getOption("abba.lower.memory.limit")) * 0.5
  expect_error(validate_memory_limit(low_value))
})

test_that("function errors when memory limit is higher than abba.memory.limit", {
  high_value <- memory_to_bytes(getOption("abba.memory.limit")) * 2
  expect_error(validate_memory_limit(high_value))
})

test_that("function returns input value when the input argument is within limits", {
  proper_value <- mean(c(memory_to_bytes(getOption("abba.lower.memory.limit")),
                         memory_to_bytes(getOption("abba.memory.limit"))))
  expect_equal(validate_memory_limit(proper_value), proper_value)
})
