## Accessing the dev Kubernetes cluster

workbench-dev.atorusresearch.com

1. Ensure you have the cluster configured at ~/.kube/configured (Eli will do this)

2. Run jobs via `kubectl apply -f <file>` where file is your YAML file.

3. check jobs with `kubectl get jobs -n rstuido`

4. Get job output with `kubectl logs -n rstudio <jobname>`

## Getting Started with 'abba'
- Use `submit_job_and_poll("path/to/your/program")` to execute and watch job.
- Use `get_job_log0("job-id")` to get the job's output.

## Explaining `inst/job.yaml` setup fields

| Placeholder        | Description |
|--------------------|-------------|
| `JOB_NAME`         | The name of the submitted job; user will give a recognizable and meaningful name upon the R function call. |
| `GENERATE_NAME`    | The prefix of the name to be generated (in case you don't want to specify a static name); usually auto-generated. |
| `BATCH_GROUP`	     | A label used to group multiple jobs for easier management and querying. This allows for batch processing and collective operations on the jobs. |
| `USER_TAG`         | Optional; can be specified by user to mark the job in some special way (i.e. "sdtm_batch"). |
| `PROGRAM_FULL_PATH`| Full program path, including extension and full path. Should be specified by user. |
| `PROGRAM_BASE_NAME`| Program name; auto-derived from `PROGRAM_FULL_NAME`. |
| `SERVICE_USER`     | A username of account with elevated privileges. This isn't something that needs to be exposed to a user. |
| `CPU_LIMIT`        | A number of CPUs available to use for this Job. Could be 1 or 2. |
| `MEMORY_LIMIT`     | An amount of memory available for this Job in MBs. Possible options: 256M, 512M, 1024M. |
| `RUN_AS_USER`      | ID of user whose identity would be used to execute the job |
| `RUN_AS_GROUP`     | Group ID whose identity would be used to execute the job |
