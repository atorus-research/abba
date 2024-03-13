test_that("abba_watch_k8s_batch_local functions correctly", {
  mock_batch_validation <- mock()
  mock_configure_k8s_yaml <- mock('configured_yaml_file')
  mock_save_yaml <- mock('yaml_file_path')
  mock_submit_k8s_yaml <- mock()

  stub(abba_submit_k8s_job_local, "validate_batch_id", mock_batch_validation)
  stub(abba_submit_k8s_job_local, "configure_k8s_yaml", mock_configure_k8s_yaml)
  stub(abba_submit_k8s_job_local, "save_yaml", mock_save_yaml)
  stub(abba_submit_k8s_job_local, "submit_k8s_yaml", mock_submit_k8s_yaml)

  result <- abba_submit_k8s_job_local('/path/to/program.R',
                                      batch_group_id='batch-id',
                                      user_tag='user_tag',
                                      cpu_limit=1,
                                      memory_limit='500M',
                                      container='unique_container',
                                      namespace='unique_namespace',
                                      username='unique_username')

  expect_called(mock_batch_validation, 1)
  expect_called(mock_configure_k8s_yaml, 1)
  expect_called(mock_save_yaml, 1)
  expect_called(mock_submit_k8s_yaml, 1)

  expect_args(mock_batch_validation, 1, 'batch-id')
  expect_args(mock_configure_k8s_yaml, 1,
              file_path='/path/to/program.R',
              batch_group_id='batch-id',
              user_tag='user_tag',
              cpu_limit= 1,
              memory_limit='500M',
              container='unique_container',
              mounts='',
              namespace='unique_namespace',
              username='unique_username')

  expect_args(mock_save_yaml, 1, 'configured_yaml_file')
  expect_args(mock_submit_k8s_yaml, 1, 'yaml_file_path')
})

test_that("abba_watch_k8s_batch_local assigns batch_group_id when it is omitted", {
  mock_batch_validation <- mock()
  mock_configure_k8s_yaml <- mock('configured_yaml_file')
  mock_save_yaml <- mock('yaml_file_path')
  mock_submit_k8s_yaml <- mock()

  stub(abba_submit_k8s_job_local, "validate_batch_id", mock_batch_validation)
  stub(abba_submit_k8s_job_local, "configure_k8s_yaml", mock_configure_k8s_yaml)
  stub(abba_submit_k8s_job_local, "save_yaml", mock_save_yaml)
  stub(abba_submit_k8s_job_local, "submit_k8s_yaml", mock_submit_k8s_yaml)

  result <- abba_submit_k8s_job_local('/path/to/program.R')

  args <- mock_args(mock_configure_k8s_yaml)
  expect_true(grepl('program', args[[1]]$batch_group_id, fixed=TRUE))

})
