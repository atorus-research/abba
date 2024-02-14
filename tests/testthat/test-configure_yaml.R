test_that("YAML fields are properly updated by configure_yaml", {
  yaml_file_configured <- abba::configure_yaml(file_path="/tst/path/test.R",
                                         batch_group_id="group_A",
                                         user_tag='user_tag',
                                         cpu_limit= 2L,
                                         memory_limit='512M')
  actual <- c(yaml_file_configured$metadata$name,
              yaml_file_configured$metadata$labels$`batch-group`,
              yaml_file_configured$spec$template$metadata$labels$`batch-group`,
              yaml_file_configured$spec$template$metadata$annotations$USER_TAG_0,
              yaml_file_configured$spec$template$spec$containers[[1]]$args[[2]],
              yaml_file_configured$spec$template$spec$containers[[1]]$resources$limits$cpu,
              yaml_file_configured$spec$template$spec$containers[[1]]$resources$limits$memory)
  
  expected <- c(yaml_file_configured$metadata$generateName,
                "group_A",
                "group_A",
                "user_tag",
                paste0("cd ~ && R --slave --no-save --no-restore -f ", "/tst/path/test.R"),
                "2",
                "512M")

  expect_equal(actual, expected)

})
