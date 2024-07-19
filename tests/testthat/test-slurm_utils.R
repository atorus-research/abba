test_that("job_statuses deciphers job statuses used by slurm", {
  coded_job_statuses <- c("BF", "CA", "CD", "CF", "CG", "DL", "F", "NF", "OOM", "PD", "PR", "R", "RD", "RF", "RH", "RQ", "RS", "RV", "SI", "SE", "SO", "ST", "S", "TO")
  expected_result <- c("BOOT_FAIL", "CANCELLED", "COMPLETED", "CONFIGURING", "COMPLETING", "DEADLINE", "FAILED", "NODE_FAIL", "OUT_OF_MEMORY", "PENDING", "PREEMPTED", "RUNNING",
                       "RESV_DEL_HOLD", "REQUEUE_FED", "REQUEUE_HOLD", "REQUEUED", "RESIZING", "REVOKED", "SIGNALING", "SPECIAL_EXIT", "STAGE_OUT", "STOPPED", "SUSPENDED", "TIMEOUT")
  actual_result <- sapply(coded_job_statuses, decode_slurm_job_status)
  names(actual_result ) <- NULL
  expect_equal(actual_result, expected_result)
})


test_that("slurm_parse_scontrol_output correctly parses output of scontrol command", {

  output <- c("JobId=71701 Name=hostname",
              "UserId=da(1000) GroupId=da(1000)",
              "Priority=66264 Account=none QOS=normal WCKey=*123",
              "JobState=COMPLETED Reason=None Dependency=(null)",
              "TimeLimit=UNLIMITED Requeue=1 Restarts=0 BatchFlag=0 ExitCode=0:0",
              "SubmitTime=2010-01-05T10:58:40 EligibleTime=2010-01-05T10:58:40",
              "StartTime=2010-01-05T10:58:40 EndTime=2010-01-05T10:58:40",
              "SuspendTime=None SecsPreSuspend=0",
              "Partition=debug AllocNode:Sid=snowflake:4702",
              "ReqNodeList=(null) ExcNodeList=(null)",
              "NodeList=snowflake0",
              "NumNodes=1 NumCPUs=10 CPUs/Task=2 ReqS:C:T=1:1:1",
              "MinCPUsNode=2 MinMemoryNode=0 MinTmpDiskNode=0",
              "Features=(null) Reservation=(null)",
              "OverSubscribe=OK Contiguous=0 Licenses=(null) Network=(null)")

  actual_result <- slurm_parse_scontrol_output(output)

  expect_equal(actual_result$JobId, "71701")
  expect_equal(actual_result$JobState, "COMPLETED")
  expect_equal(40, length(actual_result))
})


test_that("slurm_command_error_check raises an error if input has a non-zero status attribute", {

  output <- c("command output")
  attr(output, "status") <- 1

  expect_error(slurm_command_error_check(output, "Message in case of error"))
})


test_that("slurm_config_determine_log_folder returns program's parent folder if log_path=NULL", {

  actual_result <- slurm_config_determine_log_path(log_path=NULL,
                                                   program_path="path/to/program/prog_name.R")

  expect_equal("path/to/program/prog_name.log", actual_result)
})


test_that("slurm_config_determine_log_folder returns log path + program name if log_path is a path to folder", {

  actual_result <- slurm_config_determine_log_path(log_path="path/to/log",
                                                   program_path="path/to/program/prog_name.R")

  expect_equal("path/to/log/prog_name.log", actual_result)
})


test_that("slurm_config_determine_log_folder returns log path if log_path is a path to file", {

  actual_result <- slurm_config_determine_log_path(log_path="path/to/log/log_name.log",
                                                   program_path="path/to/program/prog_name.R")

  expect_equal("path/to/log/log_name.log", actual_result)
})


test_that("slurm_config_determine_log_folder gives error if program_path is an empty string or a NULL", {

  expect_error(slurm_config_determine_log_path(program_path=NULL))
  expect_error(slurm_config_determine_log_path(program_path=''))
})


test_that("get_slurm_job_log_path returns job log path", {

  mock_system2 <- mock( c("JobId=9998 Name=hostname",
                          "StdOut=/path/to/log/prog9998.log"),
                        cycle = TRUE)
  stub(get_slurm_job_log_path, "system2", mock_system2, depth=2)

  actual_result <- get_slurm_job_log_path("9998")

  expect_equal("/path/to/log/prog9998.log", actual_result)
})
