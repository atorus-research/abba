library(mockery)

test_that("create_file copies plumber.R and job.Rmd files to target directory", {

  # setup testing area and files
  temp_dir <- tempdir()
  source_dir <- file.path(temp_dir, 'source')
  dir.create(source_dir, showWarnings = FALSE)
  plumber_file <- tempfile('plumber', tmpdir=source_dir, fileext='.R')
  job_file <- tempfile('job', tmpdir=source_dir, fileext='.Rmd')
  writeLines(text = "plumber API", con = plumber_file)
  writeLines(text = "markdown file", con = job_file)

  expect_plumber_file <- file.path(temp_dir, basename(plumber_file))
  expect_job_file <- file.path(temp_dir, basename(job_file))

  mock_system_file <- mock(c(plumber_file, job_file))
  stub(create_file, "system.file", mock_system_file)

  create_file(path=temp_dir)

  expect_true(file.exists(expect_plumber_file))
  expect_true(file.exists(expect_job_file))

})

test_that("create_file gives a warning when files already exist at destination", {

  # setup testing area and files
  temp_dir <- tempdir()
  source_dir <- file.path(temp_dir, 'source')
  dir.create(source_dir, showWarnings = FALSE)
  plumber_file <- tempfile('plumber', tmpdir=source_dir, fileext='.R')
  job_file <- tempfile('job', tmpdir=source_dir, fileext='.Rmd')
  writeLines(text = "plumber API", con = plumber_file)
  writeLines(text = "markdown file", con = job_file)

  expect_plumber_file <- file.path(temp_dir, basename(plumber_file))
  expect_job_file <- file.path(temp_dir, basename(job_file))

  mock_system_file <- mock(c(plumber_file, job_file), cycle = TRUE)
  stub(create_file, "system.file", mock_system_file)

  # create files for first time
  create_file(path=temp_dir)

  # a warning should appear about files not being copied
  expect_warning(create_file(path=temp_dir))
})

test_that("create_batch_api calls create_file function", {

  # setup mocks
  mock_create_file <- mock()
  stub(create_batch_api, "create_file", mock_create_file)

  # call the function
  create_batch_api(path='/unique/path')

  # test mock calls
  expect_called(mock_create_file, 1)
  expect_args(mock_create_file, 1, "plumber.R", path='/unique/path')
})

test_that("create_batch_job calls create_file function", {

  # setup mocks
  mock_create_batch_job <- mock()
  stub(create_batch_job, "create_file", mock_create_batch_job)

  # call the function
  create_batch_job(path='/unique/path')

  # test mock calls
  expect_called(mock_create_batch_job, 1)
  expect_args(mock_create_batch_job, 1, "job.Rmd", path='/unique/path')
})
