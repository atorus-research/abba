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

test_that("Lower cpu limit is enforced", {
  yaml_file_configured <- abba::configure_yaml(file_path="/tst/path/test.R",
                                               cpu_limit= 0.0001)
  actual <- yaml_file_configured$spec$template$spec$containers[[1]]$resources$limits$cpu

  expected <- as.character(getOption("abba.lower.cpu.limit"))

  expect_equal(actual, expected)

})

test_that("Upper cpu limit is enforced", {
  yaml_file_configured <- abba::configure_yaml(file_path="/tst/path/test.R",
                                               cpu_limit= 6)
  actual <- yaml_file_configured$spec$template$spec$containers[[1]]$resources$limits$cpu

  expected <- as.character(getOption("abba.cpu.limit"))

  expect_equal(actual, expected)

})

test_that("Lower memory limit is enforced", {
  yaml_file_configured <- abba::configure_yaml(file_path="/tst/path/test.R",
                                               memory_limit= '1M')
  actual <- yaml_file_configured$spec$template$spec$containers[[1]]$resources$limits$memory

  expected <- as.character(getOption("abba.lower.memory.limit"))

  expect_equal(memory_to_bytes(actual), memory_to_bytes(expected))

})

test_that("Upper memory limit is enforced", {
  yaml_file_configured <- abba::configure_yaml(file_path="/tst/path/test.R",
                                               memory_limit= '1T')
  actual <- yaml_file_configured$spec$template$spec$containers[[1]]$resources$limits$memory

  expected <- as.character(getOption("abba.memory.limit"))

  expect_equal(memory_to_bytes(actual), memory_to_bytes(expected))

})

test_that("Container name and image can be customized", {
  expected <- list(name='custom_container_name', image='custom_container_image')

  yaml_file_configured <- abba::configure_yaml(file_path="/tst/path/test.R",
                                               container=expected)

  actual <- yaml_file_configured$spec$template$spec$containers[[1]]


  expect_equal(actual[c('name', 'image')], expected)

})

test_that("User can add custom mounts; volumeMounts are updated properly", {
  new_volumes <- list(volumes=list(list(name='mount1',
                                        nfs=list(server='0.0.0.0', path='/mnt/mount1'))),
                      volumeMounts=list(list(name='mount1', mountPath='/mnt/mount1')))

  yaml_file_configured <- abba::configure_yaml(file_path="/tst/path/test.R",
                                               mounts=new_volumes)

  actual_volumeMounts <- yaml_file_configured$spec$template$spec$containers[[1]]$volumeMounts

  expect_volumeMounts <- new_volumes$volumeMounts
  expect_equal(actual_volumeMounts, expect_volumeMounts)

})

test_that("User can add custom mounts; volumes information is updated properly", {
  new_volumes <- list(volumes=list(list(name='mount1',
                                        nfs=list(server='0.0.0.0', path='/mnt/mount1'))),
                      volumeMounts=list(list(name='mount1', mountPath='/mnt/mount1')))

  yaml_file_configured <- abba::configure_yaml(file_path="/tst/path/test.R",
                                               mounts=new_volumes)

  actual_volumes <- yaml_file_configured$spec$template$spec$volumes
  expect_volumes <- new_volumes$volumes
  expect_equal(actual_volumes, expect_volumes)

})
