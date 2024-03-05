test_that("save_yaml saves file when no file_path is specified", {
  config <- abba_load_k8s_yaml_template_local()
  config_path <- abba_save_yaml_local(config)
  expect_true(file.exists(config_path))
})

test_that("save_yaml saves file in a temporary directory when no file_path is specified", {
  config <- abba_load_k8s_yaml_template_local()
  config_path <- abba_save_yaml_local(config)
  expect_true(grepl("/tmp/", config_path, fixed=TRUE))
})

