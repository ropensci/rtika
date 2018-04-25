.onAttach <- function(libname, pkgname) {
  # IMPORTANT: this is the version check, the version tested to currently work.
  tika_jar_tested_version <- 1.18

  # Check if Java is there -------------------
  response <- tryCatch(
    rawToChar(
      sys::exec_internal(
        "java",
        "-version"
      )$stderr
    ),
    error = function(e) {
      return(as.character(NA))
    }
  )[1]

  if (is.na(response)) {
      packageStartupMessage("Could not find Java.
Type ?tika for Java installation tips.")
  } else {
    # Check the Java version   -------------------
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
      as.numeric(readLines(
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
      if (tika_version > tika_jar_tested_version) {
          packageStartupMessage("The installed Apache Tika version is higher than the version tested with 'rtika'.")
      }

      if (tika_version < tika_jar_tested_version) {
          packageStartupMessage("The installed Apache Tika .jar is outdated. To update, type:

rtika::install_tika()
")
      }
    }
  }
}
