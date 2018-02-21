.onLoad <- function(libname, pkgname) {
  char= tryCatch(system2('java','-version'
                         , stderr=TRUE
                         ,stdout=TRUE)
                        , error = function(e) return(NA))
  if(any(is.na(char))){
    packageStartupMessage("Could not access java from command line!
                          Type ?tika for configuration tips. ")
  }
  java_installed = grepl('version "1\\.[789]',char) | grepl('version "[789]', char)
  if(!any(java_installed)){
    packageStartupMessage('Please check that you have at least Java 7 or OpenJDK 1.7. 
                          Type ?tika for configuration tips.\n')
  }
}