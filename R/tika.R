#' R Interface to 'Apache Tika'
#' 
#' Extract text and metadata from over a thousand file types.
#' Get either plain text or structured \code{XHTML}.
#' Metadata includes \code{Content-Type}, character encoding, and Exif data from jpeg or tiff images. See the supported file types: \url{https://tika.apache.org/1.17/formats.html}.
#' 
#' @param input Character vector of paths to the input documents. Strings starting with 'http://','https://', or 'ftp://' are downloaded to a temporary directory first. Each file will be analyzed but not changed.
#' @param output Optional character vector of the output format. By default, \code{"text"} gets plain text without metadata. \code{"xml"} and \code{"html"} get \code{XHTML} text with metadata. \code{"jsonRecursive"} gets \code{XHTML} text and \code{json} metadata. \code{c("jsonRecursive","text")} or \code{c("J","t")} gets plain text and \code{json} metadata. See the 'Output Details' section.
#' @param output_dir Optional directory path to save the converted files in, as a side effect. See the 'Output Details' section.
#' @param n_chars Optional integer specifying the maximum number of characters returned for each document. The default is 1e+07. Higher numbers may be needed for exceptionally large files. 
#' @param java Optional command to invoke Java. For example, it could be to the full path of a particular Java version. See the Configuration section below.
#' @param jar Optional alternative path to a \code{tika-app-X.XX.jar}. Useful if this package becomes out of date.
#' @param threads Integer of the number of file consumer threads Tika uses. Defaults to 1.
#' @param args Optional character vector of additional arguments for Tika, that are not yet implemented in this R interface, in the pattern of \code{c('-arg1','setting1','-arg2','setting2')}. Currently settable arguments include \code{-timeoutThresholdMillis} (Number of milliseconds allowed to a parse before the process is killed and restarted), \code{-maxRestarts} (Maximum number of times the watchdog process will restart the child process), \code{-includeFilePat} (Regular expression to determine which files to process, e.g. \code{"(?i)\.pdf"}), \code{-excludeFilePat}, and \code{-maxFileSizeBytes}. These are documented in the .jar --help command.
#' @param quiet Logical if Tika command line messages and errors are to be supressed. Defaults to TRUE.
#' @return A character vector the same length and order as the input. If a particular file was not processed, the value at that position is an empty string. See the Output Details section below.
#' @examples
#' input= 'https://cran.r-project.org/doc/manuals/r-release/R-data.pdf'
#'
#' #extract text 
#' text = tika(input)
#' cat(substr(text[1],45,450))
#' 
#' #get metadata
#' if(requireNamespace('jsonlite')){
#'   json = tika(input,'J') # capital J is shortcut for jsonRecursive
#' 
#'   metadata = jsonlite::fromJSON(json[1])
#'   str(metadata) #meta meta-data
#' 
#'   metadata$'Content-Type' # [1] "application/pdf"
#'   metadata$producer # [1] "pdfTeX-1.40.18"
#'   metadata$'Creation-Date' # [1] "2017-11-30T13:39:02Z"
#' }
#' @section Output Details:
#' Empty output strings occur if an input file did not exist, it was a directory, or Tika could not process it. 
#' 
#' By default, \code{output = "text"} and this produces plain text but no metadata. Some formatting is preserved using tabs, newlines and spaces.
#' 
#' Setting \code{output} to either \code{"xml"} or the shortcut \code{"x"} will produce a strict form of \code{HTML} known as \code{XHTML}, with metadata in the \code{head} element of the \code{XHTML} and formatted text in the \code{body}.
#' Content retains more formatting than \code{"text"}. For example, a Word or Excel table will become a HTML \code{table}, with data in the \code{td} elements, as text nodes. The \code{"html"} option and its shortcut \code{"h"} seem to produce the same result as \code{"xml"}.
#' Parse XHTML with \code{xml2::read_html}. 
#' 
#' Setting \code{output} to \code{"jsonRecursive"} or its shortcut \code{"J"} produces a tree structure. Metadata fields are at the top level. The text will be found in the \code{X-TIKA:content} field. By default the text is \code{XHTML}. This can be changed to plain text by adding a second value, like this: \code{output=c("jsonRecursive","text")} or \code{output=c("J","t")}. Parse \code{json} with \code{jsonlite::fromJSON}. 
#'
#'  If \code{output_dir} is specified, then the converted files will also be saved to this directory. One way to get a list of the processed files is to use \code{list.files} with \code{recursive=TRUE}. The file locations within the \code{output_dir} maintain the same paths as the input files. The paths are now relative to \code{output_dir}.  Files are appended with \code{.txt} by default, but can be \code{.json}, \code{.xml}, or \code{.html} depending on the \code{output} setting.
#'  If \code{output_dir} is not specified, files are saved to a volatile tmp directory named by \code{tmpdir()} and will be taken care of when R shuts down. 
#' @section Background:
#' Tika is a foundational library for several large Apache projects such as the Apache Solr search engine. It has been in development since at least 2007. The most efficient way I've found to process tens of thousands of documents is Tika's 'batch' mode, which is used. There are potentially more things that can be done with this package, given enough time and attention, because Apache Tika includes many libraries and methods in its .jar file. The source is available at: \url{https://tika.apache.org/}. 
#' @section Configuration:
#' This package includes the \code{tika-app-X.XX.jar}. This jar works with Java 7. Tika in mid-2018 needs Java 8, so it's best to install that version if possible.
#' 
#' By default, this R package internally invokes Java by calling the \code{java} command from the command line. To specify the path to a particular Java version, set the path in the \code{java} attribute of the \code{tika} function.
#' 
#' Other command line arguments can be set with \code{args}. See the options for version 1.17 here: \url{https://tika.apache.org/1.17/gettingstarted.html}
#' 
#' Having the \code{sys} package is suggested but not required. The \code{sys} package can dramatically speed up the initial call to Java each time this function is run, which is useful if you are calling this function again and again. Installing  \code{sys} after  \code{rtika} will work as well as installing it before. If you find yourself calling \code{tika} repeatedly, consider supplying a long character vector of files to \code{input} instead of an individual file each time.
#'
#' Having the \code{data.table} package installed will slightly speed up the communication between R and Tika, but especially if there are hundreds of thousands of documents to process.

tika <- function(input, output=c('text','jsonRecursive','xml','html')[1], output_dir="", n_chars=1e+07, java = 'java',jar=system.file("java", "tika-app-1.17.jar", package = "rtika"), threads=1,args=character(), quiet=TRUE) {
  # Special thanks to Hadley for the nice git tutorial at: http://r-pkgs.had.co.nz/git.html
  # devtools::build_vignettes()
  # system('R CMD Rd2pdf ~/rtika')
  
  root = normalizePath('/',winslash = "/") 
 
  # download files, add absolute paths to input
  toDownload = grep('^(https?://|ftp://)',input, ignore.case=TRUE)
  if(length(toDownload)>0){
    rtika_download = function(url){ out = tempfile('rtika-file') ;  download.file(url,out) ; return(out) }
    urls = input[toDownload]
    tempfiles =  sapply(urls, rtika_download)
    input[toDownload]<- tempfiles
  }
  
  # TODO: config file for fine grained control over parsers, see: https://tika.apache.org/1.17/configuring.html

  # check if the input files exists and are not directories
  file_exists = file.exists(input) & !dir.exists(input)
  if(!any(file_exists)) stop('No files are found.')
  if(!all(file_exists)) warning('Some files do not exist or are directories.')
  inputFiles = normalizePath(input[file_exists] , winslash = '/')
 
   #Tika expects files to be relative to root
  inputFiles = sub(root,'',inputFiles,fixed = TRUE)
  
  # name a file list that will be passed to Tika. Files with commas and quotes appear to work with the settings below.
  fileList = tempfile('rtika-file')
  
  if(requireNamespace('data.table',quietly = TRUE)){
    data.table::fwrite( data.table::data.table(inputFiles) ,fileList ,row.names = FALSE,col.names = FALSE, sep=',', quote=FALSE )
  } else {
    utils::write.table( inputFiles ,fileList ,row.names = FALSE,col.names = FALSE, sep=',', quote=FALSE) 
  }
  fileList = normalizePath(fileList)
  # if the output directory is missing or empty, create a tmp folder
  if(missing(output_dir)||length(output_dir)==0||output_dir==""){
    #each time we will create an empty folder within the tmp folder.
    #output_dir = tempfile('tika-out')
    output_dir = file.path(tempdir(),'rtika-dir')
    # if(file.exists(output_dir)){
    #   #unlink means delete. Recursive is needed to remove a directory.
    #   if(unlink(output_dir,recursive= TRUE, force=TRUE)==1) {
    #     # 1 for failure
    #     warning('could not delete prior tmp output folder. Creating one with random name.')
    #     output_dir = tempfile('tika-out')
    #   }
    # }
    dir.create(output_dir)
  } else {
    # if an output directory is provided, check it exists.
    output_dir = tools::file_path_as_absolute(output_dir)
    if(!file.exists(output_dir)) stop('output_dir does not exist')
  }
  
  output_dir = normalizePath(output_dir, winslash = '/')
 
  output_flag= character()
  output_flag = ifelse('jsonRecursive' %in% output|'J' %in% output,'-J', output_flag) # goes first
  output_flag = c(output_flag, ifelse('text' %in% output|'t' %in% output,'-t',NA) )
  output_flag = c(output_flag, ifelse('xml' %in% output|'x' %in% output,'-x',NA) )
  output_flag = c(output_flag, ifelse('html' %in% output|'h' %in% output,'-h',NA) )
  output_flag = as.character(stats::na.omit(output_flag ))


  if(.Platform$OS.type=='windows'){
    java_args = c('-jar',shQuote(jar),'-numConsumers', as.integer(threads), args, output_flag,'-i',root,'-o',shQuote(output_dir),'-fileList',shQuote(fileList))
  } else {
    java_args = c('-jar',jar,'-numConsumers', as.integer(threads), args, output_flag,'-i',root,'-o',output_dir,'-fileList',fileList)
  }

  # Compared to system2, sys is much quicker when making a small number of calls. 
  if(requireNamespace('sys',quietly = TRUE)){
    sys::exec_wait(cmd=java[1] , args=java_args ,std_out=!quiet, std_err=!quiet )
  } else {
    system2(command=java[1] , args=java_args ,stdout=!quiet, stderr=!quiet )
  }
  
  output_file_affix = character()
  output_file_affix = ifelse('text' %in% output|'t' %in% output,'.txt',output_file_affix)
  output_file_affix = ifelse('xml' %in% output|'x' %in% output,'.xml',output_file_affix)
  output_file_affix = ifelse('html' %in% output|'h' %in% output,'.html',output_file_affix)
  output_file_affix = ifelse('jsonRecursive' %in% output|'J' %in% output,'.json',output_file_affix)
  out = character(length(input))
  n = 0
  for(i in seq_along(input)){
    if(file_exists[i]){
      n = n + 1
      #get the full path
      fp = normalizePath(file.path(output_dir,paste0(inputFiles[n],output_file_affix)))
      if(file.exists(fp)){
        out[i] = readChar(fp,nchars=n_chars[1]) 
      } 
    }
  }
  # remove tempfiles.
  
  trash_file = file.path(tempdir(),list.files(tempdir(),pattern='^rtika\\-file'))
  if(length(trash_file)>0){
     tmp= file.remove(trash_file)
  }
 
  trash_dir = file.path(tempdir(),list.files(tempdir(),pattern='^rtika\\-dir'))
  if(length(trash_dir)>0) { # paranoid.
    tmp=  unlink( trash_dir, recursive =TRUE) # does not seem to work unless force=TRUE on windows.
  }
 
  # I believe Tika's default output is UTF-16 but UTF-8 is the most supported in R
  return(enc2utf8(out))
  
}
