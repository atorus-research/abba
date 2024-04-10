test_that("abba_save_prog_cache creates correct cache file", {
  # Create a temporary program file
  program_path <- tempfile()
  writeLines("Test content", program_path)

  # Run the function
  abba_save_file_cache(program_path)

  # Check if cache file exists with correct content
  cache_file <- file.path(dirname(program_path), ".abba_cache", paste0(basename(program_path), ".cache"))
  expect_true(file.exists(cache_file))
  expect_equal(readLines(cache_file), digest::digest(program_path, algo = "md5", file = TRUE))

  # Clean up
  unlink(dirname(cache_file), recursive = TRUE)
  unlink(program_path)
})


test_that("cache_match behaves correctly", {
  # Create a temporary program file
  program_path <- tempfile()
  writeLines("Test content", program_path)

  # Initial run, no cache file exists
  expect_false(cache_match(program_path))

  # Second run, cache file exists, content hasn't changed
  expect_true(cache_match(program_path))

  # Modify the file and run again
  writeLines("Modified content", program_path)
  expect_false(cache_match(program_path))

  # Clean up
  unlink(program_path)
})


test_that("cache_match returns NA when input program_path is NULL or does not exist", {

  expect_equal(is.na(cache_match(NULL)), TRUE)
  expect_equal(is.na(cache_match('/non/existing/program/path.definitelyNotAnRprogram')), TRUE)

})
