test_that("save_yaml saves file when no file_path is specified", {
  config <- load_k8s_yaml_template()
  config_path <- save_yaml(config)
  expect_true(file.exists(config_path))
})

test_that("save_yaml saves file in a temporary directory when no file_path is specified", {
  config <- load_k8s_yaml_template()
  config_path <- save_yaml(config)
  expect_true(grepl(tempdir(), config_path, fixed=TRUE))
})

