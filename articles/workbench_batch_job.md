# Workbench Batch Jobs

``` r
library(abba)
```

## End User Facing Functions

The main **abba** function to submit batches is
[`abba_submit_batch()`](../reference/abba_submit_batch.md). It allows
user to submit a number of jobs to run in order defined by structure of
input list using runner functions supplied by user. In the example
below, `r_job_test.R` and `r_job_test2.R` will run in parallel, and the
`r_job_test3.R` will execute after both `r_job_test.R` and
`r_job_test2.R` execution is finished.

``` r
abba_submit_batch(
  list(c("/home/mike.stackhouse/test_progs/r_job_test.R",
         "/home/mike.stackhouse/test_progs/r_job_test2.R"),
       "/home/mike.stackhouse/test_progs/r_job_test3.R"),
  submit_func=abba_rslauncher_submit_job_local,
  wait_func=abba_rslauncher_watch_job_local,
  timeout_seconds = 15
  )
#  /home/yevhenii.boiko/k8s_test/r_job_test.R /home/yevhenii.boiko/k8s_test/r_job_test2.R /home/yevhenii.boiko/k8s_test/r_job_test3.R 
#  "TG9jYWw6UitNSWpxN2FaQ3JyQXRqbGQ5TzVFUT09"  "TG9jYWw6eGVremgtbGRNMFF0VDFFVG5MTEEzdz09"  "TG9jYWw6eENZb2lBR2x1RVJyZVYyelo0Z040QT09" 
```

The functions that submit programs and wait for program execution should
be specified by the user. This gives the ability to run program in
batches on all platforms supported by abba. Alternatively, user can
provide its own functions. All additional arguments besides program list
will be passed to submit_func(in the example above, `timeout_seconds`
parameter is then passed to and used in
[`abba_rslauncher_watch_job_local()`](../reference/abba_rslauncher_watch_job_local.md)
function to not wait too long before returning job IDs).

## Create a batch list from dataset

To automatically calculate batch run_group order that defines order in
which programs will be executed,
[`calculate_run_group()`](../reference/calculate_run_group.md) function
can be used:

``` r
ds <- as.data.frame(list(program_name=c("/home/yevhenii.boiko/k8s_test/r_job_test.R", "/home/yevhenii.boiko/k8s_test/r_job_test2.R", "/home/yevhenii.boiko/k8s_test/r_job_test3.R"),
                         inputs=c("raw.DM", "raw.EX,sdtm.DM", "raw.AE,sdtm.DM"),
                         outputs=c("sdtm.DM", "sdtm.EX", "sdtm.AE")))
calculate_run_group(ds, col_name='run_group')
#                                  program_name         inputs outputs run_group
# 1  /home/yevhenii.boiko/k8s_test/r_job_test.R         raw.DM sdtm.DM         1
# 2 /home/yevhenii.boiko/k8s_test/r_job_test2.R raw.EX,sdtm.DM sdtm.EX         2
# 3 /home/yevhenii.boiko/k8s_test/r_job_test3.R raw.AE,sdtm.DM sdtm.AE         2
```

This creates an additional(name configurable) column in input dataset
that will group programs for execution using `inputs` and `outputs`
values provided by user.

This dataset can be supplied to `abba_submit_batch` for execution in the
order of `run_group` column:

``` r
abba_submit_batch(calculate_run_group(ds, col_name='run_group'),
                  submit_func=abba_rslauncher_submit_job_local,
                  wait_func=abba_rslauncher_watch_job_local,
  )
#  /home/yevhenii.boiko/k8s_test/r_job_test.R /home/yevhenii.boiko/k8s_test/r_job_test2.R /home/yevhenii.boiko/k8s_test/r_job_test3.R 
#  "TG9jYWw6UGVPUVFoeVVMKys2c3M0TnZZcm9ZUT09"  "TG9jYWw6VmgrUnlueDBOLXZuVkVIYWxRa1NEZz09"  "TG9jYWw6bGlWcjdsVTRwQzIwcmlLUThzUUN4UT09" 
```

Batch log can be then obtained:

``` r
abba_rslauncher_get_job_log_local(c("TG9jYWw6UGVPUVFoeVVMKys2c3M0TnZZcm9ZUT09", "TG9jYWw6VmgrUnlueDBOLXZuVkVIYWxRa1NEZz09", "TG9jYWw6bGlWcjdsVTRwQzIwcmlLUThzUUN4UT09"))
# [[1]]
# [1] "[1] \"Program r_job_test start run timestamp: 2024-03-28 16:48:39\"" "[1] \"Program r_job_test end run timestamp: 2024-03-28 16:48:40\""  
# [3] "Warning message:"                                                    "No useful work done here. "                                         
# 
# [[2]]
# [1] "[1] \"Program r_job_test2 start run timestamp: 2024-03-28 16:48:41\"" "[1] \"Program r_job_test2 end run timestamp: 2024-03-28 16:48:42\""  
# [3] "Warning message:"                                                     "No useful work done here. "                                          
# 
# [[3]]
# [1] "[1] \"Program r_job_test3 start run timestamp: 2024-03-28 16:48:41\"" "[1] \"Program r_job_test3 end run timestamp: 2024-03-28 16:48:42\""  
# [3] "Warning message:"                                                     "No useful work done here. "                       
```

To run programs sequentially regardless of supplied grouping,
`sequential` parameter can be set to `TRUE`:

``` r
abba_submit_batch(calculate_run_group(ds, col_name='run_group'),
                  submit_func=abba_rslauncher_submit_job_local,
                  wait_func=abba_rslauncher_watch_job_local,
                  sequential=TRUE
  )
#  /home/yevhenii.boiko/k8s_test/r_job_test.R /home/yevhenii.boiko/k8s_test/r_job_test2.R /home/yevhenii.boiko/k8s_test/r_job_test3.R 
#  "TG9jYWw6cGppOTZSOXgtR3FDbGdpZGtzaVh1UT09"  "TG9jYWw6VlFhVEs4MXNlWmRmOUh1dG9PeEZFZz09"  "TG9jYWw6Um5YbzY5ZEU5bHN0ZlRTMVBZNm1DZz09" 

abba_rslauncher_get_job_log_local(c("TG9jYWw6cGppOTZSOXgtR3FDbGdpZGtzaVh1UT09","TG9jYWw6VlFhVEs4MXNlWmRmOUh1dG9PeEZFZz09","TG9jYWw6Um5YbzY5ZEU5bHN0ZlRTMVBZNm1DZz09" ))
# [[1]]
# [1] "[1] \"Program r_job_test start run timestamp: 2024-03-28 16:52:01\"" "[1] \"Program r_job_test end run timestamp: 2024-03-28 16:52:02\""  
# [3] "Warning message:"                                                    "No useful work done here. "                                         
# 
# [[2]]
# [1] "[1] \"Program r_job_test2 start run timestamp: 2024-03-28 16:52:04\"" "[1] \"Program r_job_test2 end run timestamp: 2024-03-28 16:52:05\""  
# [3] "Warning message:"                                                     "No useful work done here. "                                          
# 
# [[3]]
# [1] "[1] \"Program r_job_test3 start run timestamp: 2024-03-28 16:52:06\"" "[1] \"Program r_job_test3 end run timestamp: 2024-03-28 16:52:07\""  
# [3] "Warning message:"                                                     "No useful work done here. "                                          
```
