test_that("abba_save_file_cache creates correct cache file", {
  # Create a temporary program file and cache folder
  program_path <- tempfile()
  cache_folder <- file.path(tempdir(), "abba_cache_test")
  writeLines("Test content", program_path)

  # Run the function
  abba_save_file_cache(program_path, cache_folder=cache_folder)

  # Check if cache file exists with correct content
  cache_file <- file.path(cache_folder, paste0(basename(program_path), ".cache"))
  expect_true(file.exists(cache_file))
  expect_equal(readLines(cache_file), digest::digest(program_path, algo = "md5", file = TRUE))

  # Clean up
  unlink(cache_folder, recursive = TRUE)
  unlink(program_path)
})


test_that("abba_save_file_cache errors when cache_folder is not supplied", {
  program_path <- tempfile()
  writeLines("Test content", program_path)
  expect_error(abba_save_file_cache(program_path, cache_folder=NULL),
               "cache_folder must be supplied")
  unlink(program_path)
})


test_that("cache_match behaves correctly", {
  # Create a temporary program file and cache folder
  program_path <- tempfile()
  cache_folder <- file.path(tempdir(), "abba_cache_test")
  writeLines("Test content", program_path)

  # Initial run, no cache file exists
  expect_false(cache_match(program_path, cache_folder=cache_folder))

  # Second run, cache file exists, content hasn't changed
  expect_true(cache_match(program_path, cache_folder=cache_folder))

  # Modify the file and run again
  writeLines("Modified content", program_path)
  expect_false(cache_match(program_path, cache_folder=cache_folder))

  # Clean up
  unlink(cache_folder, recursive = TRUE)
  unlink(program_path)
})


test_that("cache_match returns NA when input program_path is NULL or does not exist", {
  cache_folder <- tempdir()
  expect_equal(is.na(cache_match(NULL, cache_folder=cache_folder)), TRUE)
  expect_equal(is.na(cache_match('/non/existing/program/path.definitelyNotAnRprogram',
                                 cache_folder=cache_folder)), TRUE)
})


test_that("cache_match errors when cache_folder is not supplied", {
  program_path <- tempfile()
  writeLines("Test content", program_path)
  expect_error(cache_match(program_path, cache_folder=NULL),
               "cache_folder must be supplied")
  unlink(program_path)
})
