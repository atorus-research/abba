# commandArgs picks up the variables you pass from the command line
args <- commandArgs(trailingOnly = TRUE)

print(args)
prog_path <- args[1]
source_file <- args[2]

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
source(prog_path)

# return to original directory
setwd(cwd)
