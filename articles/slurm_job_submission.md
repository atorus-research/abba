# SLURM Job Submission

``` r
library(abba)
```

In support for SLURM, **abba** has function to schedule and manage R
programs on connected SLURM cluster. At a high level, these functions
break down into three different categories:

- Submit a job
- Get job status
- Wait for job completion
- Retrieve the log of the job

Functions specifically for interfacing with SLURM follow the naming
convention `abba_slurm_*`.

### Submit a Job

Job submission is handled by the function
[`abba_slurm_submit_job()`](../reference/abba_slurm_submit_job.md).

``` r
abba_slurm_submit_job(
  "/home/mike.stackhouse/repos/abba/test_programs/test_program.R",
  log_path = "/home/mike.stackhouse/test_logs"
  )
# [1] "38"
```

Note that this returns a vector with job id and name being path of the
program. The Job ID is the identifier used downstream to interact with
SLURM.

`log_path` is required and specifies the directory where the program’s
log file will be written. abba does not fall back to a default location
in the user’s filespace.

### Get Job Status

Once the job is running in SLURM, **abba** can poll its status. This can
be done using the function
[`abba_slurm_get_job_status()`](../reference/abba_slurm_get_job_status.md)

``` r
abba_slurm_get_job_status("57")
# 57 
# "COMPLETED" 
```

The job statuses can be “RUNNING”, “COMPLETED”, FAILED etc. For a
complete list of SLURM job statuses, please refer to
[**documentation**](https://slurm.schedmd.com/squeue.html#SECTION_JOB-STATE-CODES).

## Get the Log Content

In this context, the “log” refers to the stdout/stderr of the program
itself. This returns into a list object with the Job ID and the
individual lines written out by the program. The content will contain
all of the console output from the program itself.

``` r
abba_slurm_get_job_log("38")
# [[1]]
# [1] "[1] 4"                   "Warning message:"        "This is a test warning " "La-di-da"                       
```

## Submit a batch of jobs to SLURM cluster

Here is an example of using SLURM submission functions in
abba_submit_batch. Additional arguments like log_path will be passed on
to submit_func

``` r
abba_submit_batch(list("/home/mike.stackhouse/repos/abba/test_programs/test_program.R", "/home/mike.stackhouse/repos/abba/test_programs/test_program.R"),
                  submit_func=abba_slurm_submit_job,
                  wait_func=abba_slurm_watch_job,
                  succeed_func=abba_slurm_get_job_succeeded,
                  log_path="/home/mike.stackhouse/test_logs")
# Submitting program:
#   /home/mike.stackhouse/repos/abba/test_programs/test_program.R
# Submitting program:
#   /home/mike.stackhouse/repos/abba/test_programs/test_program.R
# /home/mike.stackhouse/repos/abba/test_programs/test_program.R /home/mike.stackhouse/repos/abba/test_programs/test_program.R
                                                          "48"                                                           "49"                    
```
