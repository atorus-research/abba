library(mockery)

test_that("Request headers update properly with auth keys", {
  req <- httr2::request("www.google.com")
  expect_error(add_api_key_to_header(req, api_key = list()))

  old_key <- Sys.getenv("CONNECT_API_KEY")
  Sys.setenv(CONNECT_API_KEY = "12345ABCDE")
  updated_req <- add_api_key_to_header(req, api_key=Sys.getenv("CONNECT_API_KEY"))

  expect_true("Authorization" %in% names(updated_req$headers))

  Sys.setenv(CONNECT_API_KEY = old_key)
})

test_that("abba_submit_job properly unpacks the response", {
  mock_request <- mock('request1')
  mock_add_api_key_to_header <- mock('request2')
  mock_req_body_json <- mock('request3')
  mock_req_error <- mock('request4')
  mock_req_perform <- mock('request5')
  mock_resp_body_json <- mock(list(job_id=list('unique-job-id'),
                                   batch_id=list('unique-batch-id')))

  stub(abba_submit_job, "httr2::request", mock_request)
  stub(abba_submit_job, "add_api_key_to_header", mock_add_api_key_to_header)
  stub(abba_submit_job, "httr2::req_body_json", mock_req_body_json)
  stub(abba_submit_job, "httr2::req_error", mock_req_error)
  stub(abba_submit_job, "httr2::req_perform", mock_req_perform)
  stub(abba_submit_job, "httr2::resp_body_json", mock_resp_body_json)

  result_actual <- abba_submit_job('/path/to/program.R',
                                   batch_group_id='unique-batch-id',
                                   user_tag = 'unique-user-tag',
                                   cpu_limit=1,
                                   memory_limit='500M',
                                   container='container',
                                   mounts='mounts',
                                   auto_mount_home=TRUE,
                                   home_nfs_ip_address='0.0.0.0',
                                   api_address='0.0.0.0',
                                   api_key='ABBA_API_KEY')

  expect_called(mock_request, 1)
  expect_called(mock_add_api_key_to_header, 1)
  expect_called(mock_req_body_json, 1)
  expect_called(mock_req_error, 1)
  expect_called(mock_req_perform, 1)
  expect_called(mock_req_error, 1)
  expect_called(mock_resp_body_json, 1)

  expect_args(mock_request, 1, '0.0.0.0/submit-job')

  expect_args(mock_add_api_key_to_header, 1, "request1", api_key='ABBA_API_KEY')

  expect_args(mock_req_body_json, 1,
              "request2",
              list(file_path='/path/to/program.R',
                   batch_group_id='unique-batch-id',
                   user_tag='unique-user-tag',
                   cpu_limit= 1,
                   memory_limit='500M',
                   mounts='mounts',
                   container='container',
                   auto_mount_home=TRUE,
                   home_nfs_ip_address='0.0.0.0')
  )

  expect_equal(result_actual, list(job_id='unique-job-id', batch_id='unique-batch-id'))
})

test_that("abba_submit_and_get_log properly waits for job to finish and returns log", {

  # create mocks for inside functions
  mock_abba_submit_job <- mock(list(job_id='job-id1', batch_id='batch_id1'))
  mock_abba_get_job_status <- mock(
    list(Pending=list(Jobs=list(list(id='job-id1', path="/path/to/script1.R")))),
    list(Running=list(Jobs=list(list(id='job-id1', path="/path/to/script1.R")))),
    list(Succeded=list(Jobs=list(list(id='job-id1', path="/path/to/script1.R"))))
  )
  mock_abba_get_job_log <- mock(list(list(job_id='job-id1', log=c('log1', 'log2'))))

  # mock inside functions
  stub(abba_submit_and_get_log, "abba_submit_job", mock_abba_submit_job)
  stub(abba_submit_and_get_log, "abba_get_job_status", mock_abba_get_job_status)
  stub(abba_submit_and_get_log, "abba_get_job_log", mock_abba_get_job_log)

  result_actual <- abba_submit_and_get_log(
    '/path/to/program.R',
    batch_group_id='unique-batch-id',
    user_tag = 'unique-user-tag',
    cpu_limit=1,
    memory_limit='500M',
    container='container',
    mounts='mounts',
    auto_mount_home=FALSE,
    poll_interval_seconds=0.1,
    timeout_seconds=5,
    api_address='0.0.0.0',
    api_key='ABBA_API_KEY')

  expect_called(mock_abba_submit_job, 1)
  expect_called(mock_abba_get_job_status, 3)
  expect_called(mock_abba_get_job_log, 1)

  expect_args(mock_abba_submit_job, 1,
              file_path='/path/to/program.R',
              batch_group_id='unique-batch-id',
              user_tag='unique-user-tag',
              cpu_limit= 1,
              memory_limit='500M',
              mounts='mounts',
              container='container',
              auto_mount_home=FALSE,
              home_nfs_ip_address=getOption('abba.home.nfs.ip.address'),
              api_address='0.0.0.0',
              api_key='ABBA_API_KEY')

  expect_args(mock_abba_get_job_status, 1,
              "job-id1",
              api_address='0.0.0.0',
              api_key='ABBA_API_KEY')
  expect_args(mock_abba_get_job_log, 1,
              "job-id1",
              api_address='0.0.0.0',
              api_key='ABBA_API_KEY')


  expect_equal(result_actual,
               list(script1=list(job_id='job-id1', log=c('log1', 'log2'))))
})

test_that("abba_wait_for_job_log properly waits for job to finish", {

  # create mocks for inside functions
  mock_abba_get_job_status <- mock(
    list(Pending=list(Jobs=list(list(id='job-id1', path="/path/to/script1.R")))),
    list(Running=list(Jobs=list(list(id='job-id1', path="/path/to/script1.R")))),
    list(Succeded=list(Jobs=list(list(id='job-id1', path="/path/to/script1.R"))))
  )
  mock_abba_get_job_log <- mock(list(list(job_id='job-id1', log=c('log1', 'log2'))))

  # mock inside functions
  stub(abba_wait_for_job_log, "abba_get_job_status", mock_abba_get_job_status)
  stub(abba_wait_for_job_log, "abba_get_job_log", mock_abba_get_job_log)

  result_actual <- abba_wait_for_job_log(
    'job-id1',
    poll_interval_seconds=0.1,
    timeout_seconds=5,
    api_address='0.0.0.0',
    api_key='ABBA_API_KEY')

  expect_called(mock_abba_get_job_status, 3)
  expect_called(mock_abba_get_job_log, 1)

  expect_args(mock_abba_get_job_status, 1,
              "job-id1",
              api_address='0.0.0.0',
              api_key='ABBA_API_KEY')
  expect_args(mock_abba_get_job_log, 1,
              "job-id1",
              api_address='0.0.0.0',
              api_key='ABBA_API_KEY')


  expect_equal(result_actual,
               list(list(job_id='job-id1', log=c('log1', 'log2'))))
})


test_that("abba_wait_for_batch_log  properly waits for jobs to finish", {

  # create mocks for inside functions
  mock_abba_get_batch_status <- mock(
    list(Pending=list(Jobs=list(list(id='job-id1', path="/path/to/script1.R"))),
         Succeeded=list(Jobs=list(list(id='job-id2', path="/path/to/script2.R")))),
    list(Running=list(Jobs=list(list(id='job-id1', path="/path/to/script1.R"))),
         Succeeded=list(Jobs=list(list(id='job-id2', path="/path/to/script2.R")))),
    list(Succeded=list(Jobs=list(list(id='job-id1', path="/path/to/script1.R"),
                                 list(id='job-id2', path="/path/to/script2.R"))))
    )
  mock_abba_get_batch_log <- mock(list(list(job_id='job-id1', log=c('log11', 'log12')),
                                       list(job_id='job-id2', log=c('log21', 'log22'))))

  # mock inside functions
  stub(abba_wait_for_batch_log, "abba_get_batch_status", mock_abba_get_batch_status)
  stub(abba_wait_for_batch_log, "abba_get_batch_log", mock_abba_get_batch_log)

  result_actual <- abba_wait_for_batch_log(
    'batch-id1',
    poll_interval_seconds=0.1,
    timeout_seconds=5,
    api_address='0.0.0.0',
    api_key='ABBA_API_KEY')

  expect_called(mock_abba_get_batch_status, 3)
  expect_called(mock_abba_get_batch_log, 1)

  expect_args(mock_abba_get_batch_status, 1,
              "batch-id1",
              api_address='0.0.0.0',
              api_key='ABBA_API_KEY')
  expect_args(mock_abba_get_batch_log, 1,
              "batch-id1",
              api_address='0.0.0.0',
              api_key='ABBA_API_KEY')


  expect_equal(result_actual,
               list(list(job_id='job-id1', log=c('log11', 'log12')),
                    list(job_id='job-id2', log=c('log21', 'log22'))))
})

test_that("abba_get_job_log properly submits request and unpacks the response", {
  mock_request <- mock('request1')
  mock_req_method <- mock('request2')
  mock_add_api_key_to_header <- mock('request3')
  mock_req_body_json <- mock('request4')
  mock_req_error <- mock('request5')
  mock_req_perform <- mock('request6')
  mock_resp_body_json <- mock(list(list(job_id=list('job-id1'), log=list(list('log11'), list('log12'))),
                              list(job_id=list('job-id2'), log=list(list('log21'), list('log22')))))

  stub(abba_get_job_log, "httr2::request", mock_request)
  stub(abba_get_job_log, "httr2::req_method", mock_req_method)
  stub(abba_get_job_log, "add_api_key_to_header", mock_add_api_key_to_header)
  stub(abba_get_job_log, "httr2::req_body_json", mock_req_body_json)
  stub(abba_get_job_log, "httr2::req_error", mock_req_error)
  stub(abba_get_job_log, "httr2::req_perform", mock_req_perform)
  stub(abba_get_job_log, "httr2::resp_body_json", mock_resp_body_json)

  result_actual <- abba_get_job_log(c('job-id1', 'job-id2'),
                                    api_address='0.0.0.0',
                                    api_key='ABBA_API_KEY')

  expect_called(mock_request, 1)
  expect_called(mock_add_api_key_to_header, 1)
  expect_called(mock_req_body_json, 1)
  expect_called(mock_req_error, 1)
  expect_called(mock_req_perform, 1)
  expect_called(mock_req_error, 1)
  expect_called(mock_resp_body_json, 1)

  expect_args(mock_request, 1, '0.0.0.0/job-log')

  expect_args(mock_add_api_key_to_header, 1, "request2", api_key='ABBA_API_KEY')

  expect_args(mock_req_body_json, 1,
              "request1",
              list(job_ids=c('job-id1', 'job-id2'))
  )

  expect_equal(result_actual,
               list(list(job_id='job-id1', log=c('log11', 'log12')),
                    list(job_id='job-id2', log=c('log21', 'log22')))
  )
})

test_that("abba_get_batch_log properly submits request and unpacks the response", {
  mock_request <- mock('request1')
  mock_req_method <- mock('request2')
  mock_add_api_key_to_header <- mock('request3')
  mock_req_body_json <- mock('request4')
  mock_req_error <- mock('request5')
  mock_req_perform <- mock('request6')
  mock_resp_body_json <- mock(list(list(pod_id=list('pod-id1'), log=list(list('log11'), list('log12'))),
                                   list(pod_id=list('pod-id2'), log=list(list('log21'), list('log22')))))

  stub(abba_get_batch_log, "httr2::request", mock_request)
  stub(abba_get_batch_log, "httr2::req_method", mock_req_method)
  stub(abba_get_batch_log, "add_api_key_to_header", mock_add_api_key_to_header)
  stub(abba_get_batch_log, "httr2::req_body_json", mock_req_body_json)
  stub(abba_get_batch_log, "httr2::req_error", mock_req_error)
  stub(abba_get_batch_log, "httr2::req_perform", mock_req_perform)
  stub(abba_get_batch_log, "httr2::resp_body_json", mock_resp_body_json)

  result_actual <- abba_get_batch_log(c('batch-id1'),
                                      api_address='0.0.0.0',
                                      api_key='ABBA_API_KEY')

  expect_called(mock_request, 1)
  expect_called(mock_add_api_key_to_header, 1)
  expect_called(mock_req_body_json, 1)
  expect_called(mock_req_error, 1)
  expect_called(mock_req_perform, 1)
  expect_called(mock_req_error, 1)
  expect_called(mock_resp_body_json, 1)

  expect_args(mock_request, 1, '0.0.0.0/batch-log')

  expect_args(mock_add_api_key_to_header, 1, "request2", api_key='ABBA_API_KEY')

  expect_args(mock_req_body_json, 1,
              "request1",
              list(batch_id='batch-id1')
  )

  expect_equal(result_actual,
               list(list(pod_id='pod-id1', log=c('log11', 'log12')),
                    list(pod_id='pod-id2', log=c('log21', 'log22')))
  )
})

test_that("abba_get_batch_status properly submits request and unpacks the response", {
  mock_request <- mock('request1')
  mock_req_method <- mock('request2')
  mock_add_api_key_to_header <- mock('request3')
  mock_req_body_json <- mock('request4')
  mock_req_error <- mock('request5')
  mock_req_perform <- mock('request6')
  mock_resp_body_json <- mock(list(
    Pending = list(Jobs=list(list(id=list('job-id1'), path=list("/path/to/script1.R")))),
    Running = list(Jobs=list(list(id=list('job-id2'), path=list("/path/to/script2.R")))),
    Failed =  list(Jobs=list(list(id=list('job-id3'), path=list("/path/to/script3.R")))),
    Succeeded=list(Jobs=list(list(id=list('job-id4'), path=list("/path/to/script4.R")))),
    Unknown = list(Jobs=list(list(id=list('job-id5'), path=list("/path/to/script5.R"))))
  ))

  stub(abba_get_batch_status, "httr2::request", mock_request)
  stub(abba_get_batch_status, "httr2::req_method", mock_req_method)
  stub(abba_get_batch_status, "add_api_key_to_header", mock_add_api_key_to_header)
  stub(abba_get_batch_status, "httr2::req_body_json", mock_req_body_json)
  stub(abba_get_batch_status, "httr2::req_error", mock_req_error)
  stub(abba_get_batch_status, "httr2::req_perform", mock_req_perform)
  stub(abba_get_batch_status, "httr2::resp_body_json", mock_resp_body_json)

  result_actual <- abba_get_batch_status('batch-id1',
                                        api_address='0.0.0.0',
                                        api_key='ABBA_API_KEY')

  expect_called(mock_request, 1)
  expect_called(mock_add_api_key_to_header, 1)
  expect_called(mock_req_body_json, 1)
  expect_called(mock_req_error, 1)
  expect_called(mock_req_perform, 1)
  expect_called(mock_req_error, 1)
  expect_called(mock_resp_body_json, 1)

  expect_args(mock_request, 1, '0.0.0.0/batch-status')

  expect_args(mock_add_api_key_to_header, 1, "request2", api_key='ABBA_API_KEY')

  expect_args(mock_req_body_json, 1,
              "request1",
              list(batch_id='batch-id1')
  )

  expect_equal(result_actual,
               list(Pending = list(Jobs=list(list(id='job-id1', path="/path/to/script1.R"))),
                    Running = list(Jobs=list(list(id='job-id2', path="/path/to/script2.R"))),
                    Failed =  list(Jobs=list(list(id='job-id3', path="/path/to/script3.R"))),
                    Succeeded=list(Jobs=list(list(id='job-id4', path="/path/to/script4.R"))),
                    Unknown = list(Jobs=list(list(id='job-id5', path="/path/to/script5.R")))
  ))
})

test_that("abba_get_job_status properly submits request and unpacks the response", {
  mock_request <- mock('request1')
  mock_req_method <- mock('request2')
  mock_add_api_key_to_header <- mock('request3')
  mock_req_body_json <- mock('request4')
  mock_req_error <- mock('request5')
  mock_req_perform <- mock('request6')
  mock_resp_body_json <- mock(list(
    Pending = list(Jobs=list(list(id=list('job-id1'), path=list("/path/to/script1.R"))))
  ))

  stub(abba_get_job_status, "httr2::request", mock_request)
  stub(abba_get_job_status, "httr2::req_method", mock_req_method)
  stub(abba_get_job_status, "add_api_key_to_header", mock_add_api_key_to_header)
  stub(abba_get_job_status, "httr2::req_body_json", mock_req_body_json)
  stub(abba_get_job_status, "httr2::req_error", mock_req_error)
  stub(abba_get_job_status, "httr2::req_perform", mock_req_perform)
  stub(abba_get_job_status, "httr2::resp_body_json", mock_resp_body_json)

  result_actual <- abba_get_job_status('job-id1',
                                       api_address='0.0.0.0',
                                       api_key='ABBA_API_KEY')

  expect_called(mock_request, 1)
  expect_called(mock_add_api_key_to_header, 1)
  expect_called(mock_req_body_json, 1)
  expect_called(mock_req_error, 1)
  expect_called(mock_req_perform, 1)
  expect_called(mock_req_error, 1)
  expect_called(mock_resp_body_json, 1)

  expect_args(mock_request, 1, '0.0.0.0/job-status')

  expect_args(mock_add_api_key_to_header, 1, "request2", api_key='ABBA_API_KEY')

  expect_args(mock_req_body_json, 1,
              "request1",
              list(job_id='job-id1')
  )

  expect_equal(result_actual,
               list(Pending = list(Jobs=list(list(id='job-id1', path="/path/to/script1.R")))
               ))
})

test_that("submit_job_error_body returns message attribute from response body", {

  mock_resp_body_json <- mock(list(error='test_error', message='test error message'))
  stub(submit_job_error_body, "httr2::resp_body_json", mock_resp_body_json)

  result_actual <- submit_job_error_body('resp')

  expect_called(mock_resp_body_json, 1)
  expect_args(mock_resp_body_json, 1, 'resp')
  expect_equal(result_actual, 'test error message')
})

