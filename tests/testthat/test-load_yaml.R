test_that("Package job YAML file loads correctly", {
  x <- abba_load_k8s_yaml_template_local()

  expect_equal(names(x), c("kind", "apiVersion", "metadata", "spec"))
})
