#' Main R Interface to 'Apache Tika'
#'
#' Extract text or metadata from over a thousand file types.
#' Get either plain text or structured \code{XHTML}.
#' Metadata includes \code{Content-Type}, character encoding, and Exif data from
#' jpeg or tiff images. See the long list of supported file types, 
#' click the "Supported Formats" link on this page :
#' \url{https://tika.apache.org/}.
#'
#' @param input Character vector describing the paths to the input documents.
#' Strings starting with 'http://','https://', or 'ftp://' are downloaded to a
#' temporary directory. On Windows, the local paths cannot span
#' drives because of a Windows convention.
#' @param output Optional character vector of the output format. The default,
#' \code{"text"}, gets plain text without metadata. \code{"xml"} and
#' \code{"html"} get \code{XHTML} text with metadata. \code{"jsonRecursive"}
#' gets \code{XHTML} text and \code{json} metadata.
#' \code{c("jsonRecursive","text")} or \code{c("J","t")} get plain text and
#' \code{json} metadata. See the 'Output Details' section.
#' @param output_dir Optional directory path to save the converted files in.
#' Tika may overwrite files so an empty directory is best. See the 'Output
#' Details' section before using.
#' @param return Logical if an R object should be returned. Defaults to
#' TRUE. If set to FALSE, and output_dir (above) must be specified.
#' @param java Optional command to invoke Java. For example, it can be the full
#' path to a particular Java version. See the Configuration section below.
#' @param jar Optional alternative path to a \code{tika-app-X.XX.jar}. Useful
#' if this package becomes out of date.
#' @param threads Integer of the number of file consumer threads Tika uses.
#' Defaults to 2.
#' @param max_restarts Integer of the maximum number of times the watchdog
#' process will restart the child process. The default is no limit.
#' @param timeout Integer of the number of milliseconds allowed to a parse
#' before the process is killed and restarted. Defaults to 300000. 
#' @param max_file_size Integer of the maximum bytes allowed.
#' Do not process files larger than this. The default is unlimited.
#' @param config Path to the XML config file. Defaults to \code{system.file("extdata", "ocr.xml", package = "rtika")}'. There is also a \code{no-ocr.xml} file available.
#' @param args Optional character vector of additional arguments passed to Tika,
#' that may not yet be implemented in this R interface, in the pattern of
#' \code{c('-arg1','setting1','-arg2','setting2')}. 
#' @param quiet Logical if Tika command line messages and errors are to be
#' suppressed. Defaults to \code{TRUE}.
#' @param cleanup Logical to clean up temporary files after running the command,
#' which can accumulate. Defaults to \code{TRUE}. They are in \code{tempdir()}. These
#' files are automatically removed at the end of the R session even if set to
#' FALSE.
#' @param lib.loc Optional character vector describing the library paths.
#' Normally, it's best to
#' leave this parameter alone. The parameter is included
#' mainly for package testing.
#' @return A character vector in the same order and with the same length as
#' \code{input}. Unprocessed files are \code{as.character(NA)}.
#' If \code{return = FALSE}, then a \code{NULL} value is invisibly returned.
#' See the Output Details section below.
#' @examples
#' \donttest{
#' #extract text
#' batch <- c(
#'   system.file("extdata", "jsonlite.pdf", package = "rtika"),
#'   system.file("extdata", "curl.pdf", package = "rtika"),
#'   system.file("extdata", "table.docx", package = "rtika"),
#'   system.file("extdata", "xml2.pdf", package = "rtika"),
#'   system.file("extdata", "R-FAQ.html", package = "rtika"),
#'   system.file("extdata", "calculator.jpg", package = "rtika"),
#'   system.file("extdata", "tika.apache.org.zip", package = "rtika")
#' )
#' text = tika(batch)
#' cat(substr(text[1],45,450))
#'
#' #more complex metadata
#' if(requireNamespace('jsonlite')){
#'
#'   json = tika(batch,c('J','t'))
#'   # 'J' is shortcut for jsonRecursive
#'   # 't' for text
#'   metadata = lapply(json, jsonlite::fromJSON )
#'
#'   #embedded resources
#'   lapply(metadata, function(x){ as.character(x$'Content-Type') })
#'
#'   lapply(metadata, function(x){ as.character(x$'Creation-Date') })
#'
#'   lapply(metadata, function(x){  as.character(x$'X-TIKA:embedded_resource_path') })
#' }
#' }
#' @section Output Details:
#' If an input file did not exist, could not be downloaded, was a directory, or
#' Tika could not process it, the result will be \code{as.character(NA)} for
#' that file.
#'
#' By default, \code{output = "text"} and this produces plain text with no
#' metadata. Some formatting is preserved in this case using tabs, newlines and
#' spaces.
#'
#' Setting \code{output} to either \code{"xml"} or the shortcut \code{"x"} will
#' produce a strict form of \code{HTML} known as \code{XHTML}, with metadata in
#' the \code{head} node and formatted text in the \code{body}.
#' Content retains more formatting with \code{"xml"}. For example, a Word or
#' Excel table will become a HTML \code{table}, with table data as text in
#' \code{td} elements. The \code{"html"} option and its shortcut \code{"h"}
#' seem to produce the same result as \code{"xml"}.
#' Parse XHTML output with \code{xml2::read_html}.
#'
#' Setting \code{output} to \code{"jsonRecursive"} or its shortcut \code{"J"}
#' produces a tree structure in `json`. Metadata fields are at the top level.
#' The \code{XHTML} or plain text will be found in the \code{X-TIKA:content}
#' field. By default the text is \code{XHTML}. This can be changed to plain
#' text like this: \code{output=c("jsonRecursive","text")} or
#' \code{output=c("J","t")}. This syntax is meant to mirror Tika's. Parse
#' \code{json} with \code{jsonlite::fromJSON}.
#'
#'  If \code{output_dir} is specified, then the converted files will also be
#'  saved to this directory. It's best to use an empty directory because Tika
#'  may overwrite existing files. Tika seems to add an extra file extension to
#'  each file to reduce the chance, but it's still best to use an empty
#'  directory. The file locations within the \code{output_dir} maintain the same
#'  general path structure as the input files. Downloaded files have a path
#'  similar to the `tempdir()` that R uses. The original paths are now relative
#'  to \code{output_dir}.  Files are appended with \code{.txt} for the default
#'  plain text, but can be \code{.json}, \code{.xml}, or \code{.html} depending
#'  on the \code{output} setting. One way to get a list of the processed files
#'  is to use \code{list.files} with \code{recursive=TRUE}.
#'  If \code{output_dir} is not specified, files are saved to a volatile temp
#'  directory named by \code{tempdir()} and will be deleted when R shuts down.
#'  If this function will be run on very large batches repeatedly, these
#'  temporary files can be cleaned up every time by adding
#'  \code{cleanup=TRUE}.
#' @section Background:
#' Tika is a foundational library for several Apache projects such as the Apache
#' Solr search engine. It has been in development since at least 2007. The most
#' efficient way I've found to process many thousands of documents is Tika's
#' 'batch' mode, which is the only mode used in `rtika`. There are potentially
#' more things that can be done, given enough time and attention, because
#' Apache Tika includes many libraries and methods in its .jar file. The source is available at:
#' \url{https://tika.apache.org/}.
#' @section Installation:
#'  Tika requires Java 8.
#'
#'  Java installation instructions are at https://openjdk.org/install/
#' or https://www.java.com/en/download/help/download_options.xml.
#'
#' By default, this R package internally invokes Java by calling the \code{java}
#' command from the command line. To specify the path to a particular Java
#' version, set the path in the \code{java} attribute of the \code{tika}
#' function.
#'
#'
#' @export
tika <- function(input,
                 output = c("text", "jsonRecursive", "xml", "html")[1],
                 output_dir = "",
                 return = TRUE,
                 java = rtika::java(),
                 jar = rtika::tika_jar(),
                 threads = 2,
                 max_restarts = integer(),
                 timeout = 300000,
                 max_file_size = integer(),
                 config = system.file("extdata", "ocr.xml", package = "rtika"),
                 args = character(),
                 quiet = TRUE,
                 cleanup = TRUE,
                 lib.loc = .libPaths()) {

  # Special thanks to Hadley the git tutorial at:
  # http://r-pkgs.had.co.nz/git.html
    
  # To update tika version, update 
    # (1) DESCRIPTION of the Version
    # (2) R/zzz.R file variable: "tika_jar_tested_version"
    # (3) R/install_tika "version" and sha512 "digest" of tika-app at https://tika.apache.org/download.html
    # (4) NEWS.md to the verision

  # When updating the package, run these functions in order:
    # make sure required packages are installed including: devtools, knitr,rmarkdown, pkgdown
    # devtools::document() # sets up NAMESPACE and .Rd documentation files to match function
    # Use Rstudio's "Build" > "Install and Restart" 
    # if necessary, run "rtika::install_tika()" to update the .jar
    # devtools::test(); 
    # devtools::build()
    # devtools::build_vignettes()
    # Use Rstudio's "Build" > "Install and Restart" 
    # Sys.setenv(NOT_CRAN = TRUE); 
    # pkgdown::clean_site() ; pkgdown::build_site() # https://www.r-bloggers.com/building-a-website-with-pkgdown-a-short-guide/
    # Rstudio "Build" > "More" > "Build Source Package"
    # upload to github for tests!!
    # upload to CRAN
    
  
  # Suggested functions to run occasionally:
  # goodpractice::gp()
    # 
  # styler::style_dir() # note this has made some files break in the past, 

  # TODO:  memory setting with java -Xmx1024m -jar.
  # Probably also adjust child process -JXmx4g

  # Parameter sanity check --------------------------------------------

  stopifnot(
    class(input) == "character",
    length(input) > 0,
    class(output) == "character",
    length(output) > 0,
    length(output) <= 2,
    class(output_dir) == "character",
    length(output_dir) == 1,
    class(return) == "logical",
    length(return) == 1,
    class(java) == "character",
    length(java) == 1,
    !any(is.na(jar)),
    class(jar) == "character",
    length(jar) == 1,
    nchar(jar) > 0,
    class(threads) %in% c("integer", "numeric"),
    length(threads) <= 1,
    class(max_restarts) %in% c("integer", "numeric"),
    length(max_restarts) <= 1,
    class(timeout) %in% c("integer", "numeric"),
    length(timeout) <= 1,
    class(max_file_size) %in% c("integer", "numeric"),
    length(max_file_size) <= 1,
    class(config) == 'character',
    class(args) == "character",
    class(quiet) == "logical",
    class(cleanup) == "logical",
    class(lib.loc) == "character",
    ifelse(nchar(output_dir) == 0, return == TRUE, TRUE)
  )
  # TODO: consider a config file
  # for fine grained control over parsers.
  # see: https://tika.apache.org/1.19/configuring.html
  # but waiting for batch format to stabilize.

  # Define return variable structure  -----------------------------------
  # output will be character vector the same length as input,
  # with initial NAs ...
  out <- character(length(input))
  failure <- as.character(NA)
  out[out == ""] <- failure

  # Parameter tidying  ------------------------------------------------

  # output_flag is output format for Tika command line
  output_flag <- character()
  output_flag <- ifelse(any(output %in% c("jsonRecursive", "J", "-J")),
    "-J",
    output_flag
  ) # goes first
  output_flag <- c(output_flag, ifelse(any(output %in% c("text", "t", "-t")),
    "-t",
    NA
  ))
  output_flag <- c(output_flag, ifelse(any(output %in% c("xml", "x", "-x")),
    "-x",
    NA
  ))
  output_flag <- c(output_flag, ifelse(any(output %in% c("html", "h", "-h")),
    "-h",
    NA
  ))
  output_flag <- as.character(stats::na.omit(output_flag))


  # output_dir parameter stores tika's processed files.
  # If it doesn't exist, create one in the temp directory
  if (output_dir == "") {
    # The filenames are guaranteed not to be currently in use.
    output_dir <- tempfile("rtika_dir")
    dir.create(output_dir)
    output_dir <- normalizePath(output_dir, mustWork = TRUE, winslash = "/")
  } else {
    # if an output directory is provided, check it exists.
    output_dir <- normalizePath(output_dir, mustWork = TRUE, winslash = "/")
    # Must be very careful writing to any directory outside of temp directory
    # Idea here it to check its not the root directory
    if (output_dir == normalizePath("/", winslash = "/")) {
      stop("Output directory should not be the same as the system root.")
    }
  }

  # input parameter may contain URLs. Download if needed
  toDownload <- grep(
    "^(http[s]?:/|ftp:/|file:/)",
    input,
    ignore.case = TRUE
  )
  if (length(toDownload) > 0) {

    # input parameter adds downloaded file paths (if not downloaded, rtika_download produces NAs)
    urls <- input[toDownload]
    tempfiles <- tika_fetch(urls)
    input[toDownload] <- tempfiles
  }

  # Input can have issues.
  # Check if file exist, are not directories, are not NA, and were downloaded
  file_exists <- !is.na(input) & file.exists(input) & !dir.exists(input)
  if (!any(file_exists)) {
    warning("No files could be found.")
    return(out)
  }

  # inputFiles and fileList will contain files for Tika to process  --------------------------

  inputFiles <- normalizePath(input[file_exists], winslash = "/")
  # Tika expects files to be relative to root
  # NB: These paths will be READ, NOT written to!
  # Original way to get root path:
  # root <- normalizePath("/", winslash = "/")
  # on Windows, files cannot span drives. Tika expects relative paths, and Windows does not
  # allow relative paths to span drives!
  root <- regmatches(inputFiles[1],regexpr("^([A-Za-z:]*/)",inputFiles[1]))[1]
  # remove proceeding drive letter on Windows, proceeding forward slash on *nix and OS X.
  inputFiles <- sub(root, "", inputFiles, fixed = TRUE)

  # fileList is a delimited version if inputFiles that will be passed to Tika.
  # File paths containing both commas and quote characters appear to work.
  fileList <- normalizePath(tempfile("rtika_file"), mustWork = FALSE, winslash = "/")


    utils::write.table(
      inputFiles,
      fileList, row.names = FALSE,
      col.names = FALSE,
      sep = ",",
      quote = FALSE
    )
    
  # After the file is created, make sure it exists
  if (!file.exists(fileList)) {
    stop('Could not write to the tempfile for "fileList": ', fileList)
  }

  # java call  -----------------------------------------------------
  numConsumers <- character()
  maxRestarts <- character()
  timeoutThresholdMillis <- character()
  maxFileSizeBytes <- character()
  configTika <- character()

  if (length(threads) > 0) {
    numConsumers <- c("-numConsumers", as.character(as.integer(threads)))
  }

  if (length(max_restarts) > 0) {
    maxRestarts <- c("-maxRestarts", as.character(as.integer(max_restarts)))
  }

  if (length(timeout) > 0) {
    timeoutThresholdMillis <- c("-timeoutThresholdMillis", as.character(as.integer(timeout)))
  }

  if (length(maxFileSizeBytes) > 0) {
    maxFileSizeBytes <- c("-maxFileSizeBytes", as.character(as.integer(max_file_size)))
  }
  
  if (length(config) > 0 && nchar(config[1]) > 0) {
      configTika <- c("-c", config[1])
  }
  
  
    java_args <- c(
      "-Djava.awt.headless=true",
      "-jar", jar,
      numConsumers,
      maxRestarts,
      timeoutThresholdMillis,
      maxFileSizeBytes,
      configTika,
      args, output_flag, "-i", root,
      "-o", output_dir,
      "-fileList", fileList
    )

  sys::exec_wait(
    cmd = java[1], args = java_args, std_out = !quiet,
    std_err = !quiet, std_in = FALSE
  )

  # retrieve results  --------------------------------------------------------
  if (return) {
    output_file_affix <- character()
    output_file_affix <- ifelse(any(output %in% c("text", "t", "-t")),
      ".txt",
      output_file_affix
    )
    output_file_affix <- ifelse(any(output %in% c("xml", "x", "-x")),
      ".xml",
      output_file_affix
    )
    output_file_affix <- ifelse(any(output %in% c("html", "h", "-h")),
      ".html",
      output_file_affix
    )
    output_file_affix <- ifelse(any(output %in% c("jsonRecursive", "J", "-J")),
      ".json",
      output_file_affix
    )

    # Vectorized readChar
    .rtika_readFile <- function(path) {
      bytes <- file.size(path)
      ifelse(!is.na(bytes), mapply(
        readChar,
        con = path,
        nchars = bytes,
        useBytes = TRUE
      ),
      as.character(NA)
      )
    }

    # Clean & check with normalizePath, with warnings if not processed.
    output_files <- normalizePath(
      file.path(
        output_dir,
        paste0(
          inputFiles,
          output_file_affix
        )
      ),
      winslash = "/"
    )

    out[file_exists] <- .rtika_readFile(output_files)


    # From studying the source code, the Tika batch processor defaults to UTF-8
    # every batch config xml file uses a FSOutputStreamFactory set to UTF-8

    # cleanup temp files  -----------------------------------------------------
    if (cleanup) {
      trash_file <- file.path(normalizePath(tempdir()), list.files(
        tempdir(),
        pattern = "^rtika_file"
      ))
      if (length(trash_file) > 0) {
        tmp <- file.remove(trash_file)
      }

      trash_dir <- file.path(normalizePath(tempdir()), list.files(
        tempdir(),
        pattern = "^rtika_dir"
      ))
      if (length(trash_dir) > 0) {
        # if(.Platform$OS.type=='windows'){
        # On windows, deleting dir does not seem to work unless force=TRUE.
        # but do not want to force this.
        #   tmp=  unlink( trash_dir, recursive =TRUE, force=TRUE)
        # } else {
        tmp <- unlink(trash_dir, recursive = TRUE)
        # }
      }
    }
    return(out)
  } else {
    # if return==FALSE
    invisible(NULL)
  }
}
