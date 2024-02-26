test_that("Numeric values are unchanged", {
  expect_equal(memory_to_bytes(1000), 1000)
})

test_that("Ceiling value is used if fractions are supplied", {
  expect_equal(memory_to_bytes(100.5), 101)
})

test_that("Ceiling value is used if fractions are supplied - in character form", {
  expect_equal(memory_to_bytes('128.1'), 129)
})

test_that("Kilobyte units are correctly converted to bytes", {
  expect_equal(memory_to_bytes('1k'), 1e3)
})

test_that("Megabyte units are correctly converted to bytes", {
  expect_equal(memory_to_bytes('128M'), 128e6)
})

test_that("Gigabytes units are correctly converted to bytes", {
  expect_equal(memory_to_bytes('2.1G'), 2.1e9)
})

test_that("Terabytes units are correctly converted to bytes", {
  expect_equal(memory_to_bytes('0.5T'), 0.5e12)
})

test_that("Kikibyte units are correctly converted to bytes", {
  expect_equal(memory_to_bytes('1ki'), 1024)
})

test_that("Mebibyte units are correctly converted to bytes", {
  expect_equal(memory_to_bytes('128Mi'), 128*1024**2)
})

test_that("Gibibytes units are correctly converted to bytes", {
  expect_equal(memory_to_bytes('2.1Gi'), 2.1*1024**3)
})

test_that("Tebibytes units are correctly converted to bytes", {
  expect_equal(memory_to_bytes('0.5Ti'), 0.5*1024**4)
})

test_that("Function errors when crazy/unrecognized units are supplied", {
  expect_error(memory_to_bytes('0.5P'))
})
