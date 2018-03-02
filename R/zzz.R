.onLoad <- function(libname, pkgname) {
  char <- tryCatch(
    system2(
      "java", "-version",
      stderr = TRUE,
      stdout = TRUE
    ),
    error = function(e) return(NA)
  )
  if (any(is.na(char))) {
    warning("Could not access java from command line!
                          Type ?tika for tips. ")
  }
  java_installed <- grepl('version "1\\.[789]', char) | grepl('version "[789]', char)
  if (!any(java_installed)) {
    warning("Please check you have at least Java 7 or OpenJDK 1.7. \n Type ?tika for tips.\n")
  }
}
