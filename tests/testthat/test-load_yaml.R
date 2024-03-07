test_that("Package job YAML file loads correctly", {
  x <- load_k8s_yaml_template()

  expect_equal(names(x), c("kind", "apiVersion", "metadata", "spec"))
})
