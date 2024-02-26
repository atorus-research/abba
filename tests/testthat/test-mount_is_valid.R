test_that("Mount information can only be supplied in a list type", {
  expect_error(mount_is_valid(1))
})

test_that("Mount names in volumes and volumeMounts should not differ", {
  mount_info <- list(volumes=list(list(name='mount0')),
                     volumeMounts=list(list(name='mount1')))
  expect_error(mount_is_valid(mount_info))
})

test_that("Mount names in volumes and volumeMounts should be the same", {
  mount_info <- list(volumes=list(list(name='mount0')),
                     volumeMounts=list(list(name='mount0')))
  expect_equal(mount_is_valid(mount_info), TRUE)
})

test_that("Length of volumes and volumeMounts should not differ", {
  mount_info <- list(volumes=list(list(name='mount0'), list(name='mount1')),
                     volumeMounts=list(list(name='mount0')))
  expect_error(mount_is_valid(mount_info))
})
