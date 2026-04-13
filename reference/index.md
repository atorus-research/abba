# Package index

## All functions

- [`abba_get_batch_log()`](abba_get_batch_log.md) : Send GET request to
  get logs of all jobs in a batch
- [`abba_get_batch_status()`](abba_get_batch_status.md) : Send GET
  request to get batch job statuses
- [`abba_get_job_log()`](abba_get_job_log.md) : Send GET request to get
  logs of specified Jobs
- [`abba_get_job_status()`](abba_get_job_status.md) : Send GET request
  to get job status
- [`abba_get_k8s_batch_log_local()`](abba_get_k8s_batch_log_local.md) :
  Return list of logs for jobs that are marked with a given batch ID
- [`abba_get_k8s_batch_status_local()`](abba_get_k8s_batch_status_local.md)
  : Get status of all jobs in a batch
- [`abba_get_k8s_job_log_local()`](abba_get_k8s_job_log_local.md) : Get
  log for every job specified in an input vector/list
- [`abba_get_k8s_job_status_local()`](abba_get_k8s_job_status_local.md)
  : Get status of all pods that belong to a job
- [`abba_rslauncher_get_job_status_local()`](abba_rslauncher_get_job_status_local.md)
  : Get Workbench job status for a given vector/list of job IDs
- [`abba_rslauncher_get_job_succeeded_local()`](abba_rslauncher_get_job_succeeded_local.md)
  : Check whether Workbench jobs have been fully executed.
- [`abba_rslauncher_submit_job_local()`](abba_rslauncher_submit_job_local.md)
  : Create a job for executing an R program
- [`abba_rslauncher_submit_logrx_job_local()`](abba_rslauncher_submit_logrx_job_local.md)
  : Execute programs via logrx
- [`abba_rslauncher_watch_job_local()`](abba_rslauncher_watch_job_local.md)
  : Periodically poll Workbench jobs for status and return their IDs
  when all job statuses arrive at 'Finished' state
- [`abba_slurm_get_job_log()`](abba_slurm_get_job_log.md) : Return job
  log for each submitted job ID
- [`abba_slurm_get_job_status()`](abba_slurm_get_job_status.md) : Return
  descriptive job status for slurm jobs
- [`abba_slurm_get_job_succeeded()`](abba_slurm_get_job_succeeded.md) :
  Check whether SLURM jobs have been fully executed.
- [`abba_slurm_submit_job()`](abba_slurm_submit_job.md) : Submit R
  program as a SLURM job
- [`abba_slurm_watch_job()`](abba_slurm_watch_job.md) : Watch SLURM job,
  periodically polling its execution status.
- [`abba_submit_and_get_log()`](abba_submit_and_get_log.md) : Send job
  and poll for status. This function sends multiple requests so it won't
  time out on heavy jobs
- [`abba_submit_batch()`](abba_submit_batch.md) : Submit programs for
  execution in order defined by structure of input list. Programs inside
  sublists will be executed in parallel, and sublists themselves would
  be submitted sequentially.
- [`abba_submit_batch_and_get_results()`](abba_submit_batch_and_get_results.md)
  : Submit programs for execution in order defined by structure of input
  list.
- [`abba_submit_job()`](abba_submit_job.md) : Send POST request to
  submit-job endpoint
- [`abba_submit_k8s_job_and_poll_local()`](abba_submit_k8s_job_and_poll_local.md)
  : Submit a job profile for execution on a Kubernetes cluster and poll
  for completion
- [`abba_submit_k8s_job_local()`](abba_submit_k8s_job_local.md) : Submit
  an R program for execution on a Kubernetes cluster
- [`abba_wait_for_batch_log()`](abba_wait_for_batch_log.md) : Monitor
  batch status and retrieve its log when the all jobs in batch finish
  running
- [`abba_wait_for_job_log()`](abba_wait_for_job_log.md) : Monitor job
  status and retrieve its log when the job finishes running
- [`abba_watch_k8s_batch_local()`](abba_watch_k8s_batch_local.md) :
  Watch a K8S batch that has been submitted to Workbench, periodically
  polling it's execution status.
- [`abba_watch_k8s_job_local()`](abba_watch_k8s_job_local.md) : Watch a
  K8S job that has been submitted to Workbench, periodically polling
  it's execution status.
- [`calculate_run_group()`](calculate_run_group.md) : Calculate
  run_group variable using inputs and outputs of programs supplied by
  user
- [`create_batch_api()`](create_batch.md)
  [`create_batch_job()`](create_batch.md) : Create a Batch API or Job
  file template
- [`submit_k8s_yaml()`](submit_k8s_yaml.md) : Submit a job profile for
  execution on a Kubernetes cluster
