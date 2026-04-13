# Calculate run_group variable using inputs and outputs of programs supplied by user

Calculate run_group variable using inputs and outputs of programs
supplied by user

## Usage

``` r
calculate_run_group(x, col_name = "run_group")
```

## Arguments

- x:

  input data frame. Must contain columns 'inputs', 'outputs' that list
  input/output datasets for each program

- col_name:

  name of newly created variable. Defaults to 'run_group_calculated'

## Value

an input data frame with one new column

## Examples

``` r
input_ds <- as.data.frame(list(program_name=c('prog1.R', 'prog2.R'),
                               inputs=c('ds0.xpt', 'ds1.xpt'),
                               outputs=c('ds1.xpt', 'ds2.xpt')))
batch_ready <- calculate_run_group
```
