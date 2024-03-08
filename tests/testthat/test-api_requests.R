test_that("Request headers update properly with auth keys", {
  req <- httr2::request("www.google.com")
  expect_error(add_api_key_to_header(req, api_key = list()))

  old_key <- Sys.getenv("CONNECT_API_KEY")
  Sys.setenv(CONNECT_API_KEY = "12345ABCDE")
  updated_req <- add_api_key_to_header(req, api_key=Sys.getenv("CONNECT_API_KEY"))

  expect_equal(updated_req$headers$Authorization, "Key 12345ABCDE")

  Sys.setenv(CONNECT_API_KEY = old_key)
})
