test_that("function errors when mount information is not a list type", {
  expect_error(mount_is_valid(1))
})

test_that("function errors when mount names in volumes and volumeMounts differ", {
  mount_info <- list(volumes=list(list(name='mount0')),
                     volumeMounts=list(list(name='mount1')))
  expect_error(mount_is_valid(mount_info))
})

test_that("Mount names in volumes and volumeMounts should be the same", {
  mount_info <- list(volumes=list(list(name='mount0')),
                     volumeMounts=list(list(name='mount0')))
  expect_equal(mount_is_valid(mount_info), TRUE)
})

test_that("function errors when length of volumes and volumeMounts differ", {
  mount_info <- list(volumes=list(list(name='mount0'), list(name='mount1')),
                     volumeMounts=list(list(name='mount0')))
  expect_error(mount_is_valid(mount_info))
})
