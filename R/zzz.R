.onLoad <- function(libname, pkgname) {
  tika_jar_version <- 1.17

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
    warning("Could not find Java.
Type ?tika for Java installation tips.")
  } else {

    # Open-JDK dropped the initial 1 since version 9
    # See http://openjdk.java.net/projects/jdk9/
    # See http://openjdk.java.net/jeps/223

    java_installed <- (
      grepl('version "1\\.(7|8)', response)
      | grepl('version "(7|8|9|1[0-9])', response)
    )

    if (!java_installed) {
      warning("Found Java, but not version 7 or above.
Type ?tika for Java installation tips.")
    }
  }

  tika_installed <- tika_jar()

  if (is.na(tika_installed)) {
    warning("To finish installing 'rtika', type:

rtika::install_tika()
")
  } else {
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
      warning("Could not determine the Apache Tika version installed.
Try reinstalling with:

rtika::install_tika()
")
    } else {
      if (tika_version > tika_jar_version) {
        warning("The installed Apache Tika version is higher than the version tested with this package.")
      }

      if (tika_version < tika_jar_version) {
        warning("The installed Apache Tika .jar is outdated. To update, type:

rtika::install_tika()
")
      }
    }
  }
}
