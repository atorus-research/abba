test_that("Request is not modified if api_key is NULL", {
  req <- httr2::request("base_url") %>% add_api_key_to_header(api_key=NULL)
  actual <- list()
  expect_equal(req$headers, actual)
})

test_that("Request is not modified if api_key is an empty string", {
  req <- httr2::request("base_url") %>% add_api_key_to_header(api_key='')
  actual <- list()
  expect_equal(req$headers, actual)
})

test_that("function errors when api_key is not NULL or character", {
  expect_error(httr2::request("base_url") %>%
                 add_api_key_to_header(api_key=list(api_key='asdk')))
})

test_that("Function adds proper header when api_key is supplied", {
  req <- httr2::request("base_url") %>% add_api_key_to_header(api_key='test_key')
  actual <- list(Authorization='Key test_key')
  expect_equal(req$headers, actual)
  })
