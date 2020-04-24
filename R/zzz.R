.onAttach <- function(libname, pkgname) {
  # IMPORTANT: this is the version check, the version tested to currently work.
  tika_jar_tested_version <- "1.24.1" 

  # Check if Java is there -------------------
  
  if (.Platform$OS.type == "windows") {
      response <- tryCatch(
          rawToChar(
              sys::exec_internal(
                  shQuote(rtika::java()),
                  "-version"
              )$stderr
          ),
          error = function(e) {
              return(as.character(NA))
          }
      )[1]
  } else {
      response <- tryCatch(
          rawToChar(
              sys::exec_internal(
                  rtika::java(),
                  "-version"
              )$stderr
          ),
          error = function(e) {
              return(as.character(NA))
          }
      )[1]
  }
 
  if(is.na(response)) {
      packageStartupMessage("Could not find Java.
Type ?tika for Java installation tips.")
  } else {
    # Check the Java version  -------------------
    # Open-JDK dropped the initial 1 since version 9
    # See http://openjdk.java.net/projects/jdk9/
    # See http://openjdk.java.net/jeps/223
   
      
    java_version_check <- (
      grepl('version "1\\.8', response)
      | grepl('version "(8|9|1[0-9])', response)
    )

    if (!java_version_check) {
        packageStartupMessage("Found Java, but not the correct version.
Type ?tika for Java installation tips.")
    }
  }

  # Check if Tika .jar is installed   -------------------
  tika_installed <- tika_jar()

  if (is.na(tika_installed)) {
      packageStartupMessage("To finish installing 'rtika', type:

rtika::install_tika()
")
  } else {
    # Check if Tika .jar version from .txt file  -------------------
      
    tika_version <- tryCatch(
      as.character(readLines(
        file.path(
          rappdirs::user_data_dir("rtika"),
          "tika-app-version.txt"
        )
      )),
      error = function(x) {
        return(as.character(NA))
      }
    )

    if (is.na(tika_version)) {
        packageStartupMessage("Could not determine the Apache Tika version installed.
Try reinstalling with:

rtika::install_tika()
")
    } else {
        # semantic variable comparison
        .semver_compare <- function(a, b) {
             pa = strsplit(a, '.', fixed = TRUE)[[1]]
             pb = strsplit(b,'.', fixed = TRUE)[[1]]
            for (i in 1:3) {
                
                na = as.numeric(pa[i])
                 nb = as.numeric(pb[i])
                 if (is.na(na) && is.na(nb))  { return(0)}
                if (!is.na(na) && is.na(nb)) { return(1) }
                if (is.na(na) && !is.na(nb)) { return(-1)}
               
                if (na > nb) { return(1) }
                if (nb > na) { return(-1)}
            }
            return(0);
        }
        
        
      if (.semver_compare(tika_version,tika_jar_tested_version) > 0) {
          packageStartupMessage("The installed Apache Tika version is higher than the version tested with 'rtika'.")
      }

      if (.semver_compare(tika_version,tika_jar_tested_version) < 0) {
          packageStartupMessage("The installed Apache Tika .jar is outdated. To update, type:

rtika::install_tika()
")
      }
    }
  }
}
