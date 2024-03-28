test_that("YAML fields are properly updated by configure_yaml", {
  yaml_file_configured <- configure_k8s_yaml(file_path="/tst/path/test.R",
                                             batch_group_id="group_A",
                                             user_tag='user_tag',
                                             cpu_limit= 2L,
                                             memory_limit='512M',
                                             username='test_username',
                                             namespace='test_namespace',
                                             auto_mount_home=TRUE,
                                             home_nfs_ip_address='0.1.2.3'
                                             )
  actual <- c(yaml_file_configured$metadata$name,
              yaml_file_configured$metadata$namespace,
              yaml_file_configured$metadata$labels$`batch-group`,
              yaml_file_configured$spec$template$metadata$labels$`batch-group`,
              yaml_file_configured$spec$template$metadata$annotations$USER_TAG_0,
              yaml_file_configured$spec$template$spec$containers[[1]]$args[[2]],
              yaml_file_configured$spec$template$spec$containers[[1]]$resources$limits$cpu,
              yaml_file_configured$spec$template$spec$containers[[1]]$resources$limits$memory,
              yaml_file_configured$spec$template$metadata$annotations$user,
              yaml_file_configured$spec$template$spec$volumes[[1]]$nfs$server)

  expected <- c(yaml_file_configured$metadata$generateName,
                'test_namespace',
                "group_A",
                "group_A",
                "user_tag",
                paste0("cd ~ && R --slave --no-save --no-restore -f ", "/tst/path/test.R"),
                "2",
                "512M",
                'test_username',
                '0.1.2.3')

  expect_equal(actual, expected)

})

test_that("function errors when cpu limit is lower than minimum specified in options", {
  low_cpu_limit <- mcpu_to_cpu(getOption("abba.lower.cpu.limit")) * 0.1
  expect_error(configure_k8s_yaml(file_path="/tst/path/test.R",
                              cpu_limit= low_cpu_limit))
})

test_that("function errors when cpu limit is bigger than maximum cpu limit specified in options", {
  high_cpu_limit <- mcpu_to_cpu(getOption("abba.cpu.limit")) * 10
  expect_error(configure_k8s_yaml(file_path="/tst/path/test.R",
                              cpu_limit= high_cpu_limit))
})

test_that("function errors when memory limit is lower than minimum specified in options", {
  low_memory_limit <- memory_to_bytes(getOption("abba.lower.memory.limit")) * 0.1
  expect_error(abba_configure_k8s_yaml_local(file_path="/tst/path/test.R",
                              memory_limit = low_memory_limit))

})

test_that("function errors when memory limit is bigger than maximum specified in options", {
  high_memory_limit <- memory_to_bytes(getOption("abba.memory.limit")) * 10
  expect_error(abba_configure_k8s_yaml_local(file_path="/tst/path/test.R",
                              memory_limit = high_memory_limit))

})

test_that("Container image can be customized", {
  yaml_file_configured <- configure_k8s_yaml(file_path="/tst/path/test.R",
                                             container='custom_container_image')

  actual <- yaml_file_configured$spec$template$spec$containers[[1]]


  expect_equal(actual[['image']], 'custom_container_image')

})

test_that("User can add custom mounts; volumeMounts are updated properly", {
  new_volumes <- list(volumes=list(list(name='mount1',
                                        nfs=list(server='0.0.0.0', path='/mnt/mount1'))),
                      volumeMounts=list(list(name='mount1', mountPath='/mnt/mount1')))

  yaml_file_configured <- configure_k8s_yaml(file_path="/tst/path/test.R",
                                             mounts=new_volumes,
                                             auto_mount_home = TRUE)

  actual_volumeMounts <- yaml_file_configured$spec$template$spec$containers[[1]]$volumeMounts

  expect_volumeMounts <-
    c(yaml_file_configured$spec$template$spec$containers[[1]]$volumeMounts[1],
      new_volumes$volumeMounts)
  expect_equal(actual_volumeMounts, expect_volumeMounts)

})

test_that("User can add custom mounts; volumes information is updated properly", {
  new_volumes <- list(volumes=list(list(name='mount1',
                                        nfs=list(server='0.0.0.0', path='/mnt/mount1'))),
                      volumeMounts=list(list(name='mount1', mountPath='/mnt/mount1')))

  yaml_file_configured <- configure_k8s_yaml(file_path="/tst/path/test.R",
                                             mounts=new_volumes)

  actual_volumes <- yaml_file_configured$spec$template$spec$volumes
  expect_volumes <- new_volumes$volumes
  expect_equal(actual_volumes, expect_volumes)

})

test_that("Home mount is present when auto_home_mount is TRUE", {
  new_volumes <- list(volumes=list(list(name='mount1',
                                        nfs=list(server='0.0.0.0', path='/mnt/mount1'))),
                      volumeMounts=list(list(name='mount1', mountPath='/mnt/mount1')))

  yaml_file_configured <- configure_k8s_yaml(file_path="/tst/path/test.R",
                                             auto_mount_home=TRUE,
                                             mounts=new_volumes)

  actual_volumes <- yaml_file_configured$spec$template$spec$volumes
  expect_volumes <- c(yaml_file_configured$spec$template$spec$volumes[1],
                      new_volumes$volumes)
  expect_equal(actual_volumes, expect_volumes)

})
