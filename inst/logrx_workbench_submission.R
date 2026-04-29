if (!requireNamespace("logrx", quietly = TRUE)) {
  stop("logrx package is not installed. Install logrx package to submit programs via logrx.")
}

# commandArgs picks up the variables you pass from the command line
args <- commandArgs(trailingOnly = TRUE)

prog_path <- args[1]
log_path <- dirname(args[2])
log_name <- basename(args[2])
source_file <- args[3]

# remember current dir and ensure it is restored
cwd <- getwd()
on.exit(if (exists("cwd")) setwd(cwd), add = TRUE)

# source .Rprofile(or any other file) if supplied
if (!is.na(source_file)){
  # source the file from within its parent directory
  setwd(dirname(source_file))
  source(source_file)
}

# main program path should always come as a first argument. It will be executed/sourced
# last. Source the file from within its parent directory
setwd(dirname(prog_path))

logrx::axecute(prog_path, log_name = log_name, log_path = log_path)
