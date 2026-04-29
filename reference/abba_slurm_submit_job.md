# Submit R program as a SLURM job

Submit R program as a SLURM job

## Usage

``` r
abba_slurm_submit_job(
  program_path,
  log_path,
  r_version = NULL,
  user_tag = NULL,
  cpu_cores = getOption("abba.slurm.cpu.cores"),
  memory = getOption("abba.slurm.memory"),
  username = NULL,
  working_dir = NULL,
  job_timeout = 3600,
  ...
)
```

## Arguments

- program_path:

  Full path to the R program file. Must be accessible from the SLURM
  node

- log_path:

  Parent folder for the program's log file. Required; must be supplied
  explicitly so that logs are never written to an unexpected location in
  the user's filespace.

- r_version:

  Version of R that will be used to run the program. Can be specified as
  a full path to Rscript executable, or as a label of R version that is
  displayed in the Workbench GUI.

- user_tag:

  custom string that will be added to the job name.

- cpu_cores:

  Amount of CPU cores that will be requested for the job.

- memory:

  Amount of RAM in megabytes that will be requested for the job.

- username:

  user whose permission level is used to execute the script. Defaults to
  user submitting the job.

- working_dir:

  working directory for the SLURM job. Defaults to parent directory of
  `program_path`.

- job_timeout:

  time limit for a job. Must be specified in a format of
  "days-hours:minutes:seconds" If exceeded, job will be cancelled.

- ...:

  additional arguments (currently unused)

## Value

job ID

## Examples

``` r
if (FALSE) { # \dontrun{
job_id <- abba_slurm_submit_job("/home/user/tfl/t1_dm.sas",
                                log_path = "/home/user/tfl/logs")
 } # }
```
