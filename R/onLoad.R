.onLoad <- function(libname, pkgname) {
  check_version = function(raw){
    char = rawToChar(raw)
    java_installed = grepl('version "1\\.[789]',char) | grepl('version "[789]\\.', char)
    if(!java_installed){
      message('Please check that you have at least Java 7 or OpenJDK above 1.7 accessible from the command line! Type ?tika for configuration tips.\n')
    }
  }
  tmp= sys::exec_wait('java','-version', std_err = check_version)
}