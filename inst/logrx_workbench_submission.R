require(logrx)
# commandArgs picks up the variables you pass from the command line
args <- commandArgs(trailingOnly = TRUE)

prog_path <- args[1]
log_path <- dirname(args[2])
log_name <- basename(args[2])
source_file <- args[3]

# remember current dir
cwd <- getwd()

# source .Rprofile(or any other file) if supplied
if (!is.na(source_file)){
  # source the file from within it`s parent directory
  setwd(dirname(source_file))
  source(source_file)
}

# main program path should always come as a first argument. It will be executed/sourced
# last. Source the file from within it`s parent directory
setwd(dirname(prog_path))

axecute(prog_path, log_name = log_name, log_path = log_path)

# return to original directory
setwd(cwd)
