test_that("YAML fields are properly updated by configure_yaml", {
  yaml_file <- load_yaml_template()
  yaml_file_configured <- configure_yaml(yaml_file,
                                         file_path="/tst/path/test.R",
                                         user_tag='user_tag',
                                         cpu_limit= 2L,
                                         memory_limit='512M')
  actual <- c(yaml_file_configured$metadata$name,
              yaml_file_configured$spec$template$spec$containers[[1]]$args[[2]],
              yaml_file_configured$spec$template$spec$containers[[1]]$resources$limits$cpu,
              yaml_file_configured$spec$template$spec$containers[[1]]$resources$limits$memory)

  expected <- c(yaml_file_configured$metadata$generateName,
                paste0("cd ~ && R --slave --no-save --no-restore -f ", "/tst/path/test.R"),
                "2",
                "512M")

  expect_equal(actual, expected)

})
