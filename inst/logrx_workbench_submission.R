require(logrx)
# commandArgs picks up the variables you pass from the command line
args <- commandArgs(trailingOnly = TRUE)

prog_path <- args[1]
log.path <- file.path(dirname(prog_path), "log")
log.name <- paste0(tools::file_path_sans_ext(basename(prog_path)), '.log')

axecute(prog_path, log_name = log.name, log_path = log.path)
