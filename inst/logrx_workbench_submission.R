require(logrx)
# commandArgs picks up the variables you pass from the command line
args <- commandArgs(trailingOnly = TRUE)

print(args)
prog_path <- args[1]
log_path <- dirname(args[2])
log_name <- basename(args[2])

axecute(prog_path, log_name = log_name, log_path = log_path)
