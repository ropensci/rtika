#' R Interface to 'Apache Tika'
#' 
#' Extract text and metadata from over a thousand file types.
#' Get either plain text or structured \code{XHTML}.
#' Metadata includes \code{Content-Type}, character encoding, and Exif data from jpeg or tiff images. See the supported file types: \url{https://tika.apache.org/1.17/formats.html}.
#' 
#' @param input Character vector of paths to the input documents. Strings starting with 'http://','https://', or 'ftp://' are downloaded to a temporary directory first. Each file will be analyzed but not changed.
#' @param output Optional character vector of the output format. By default, \code{"text"} gets plain text without metadata. \code{"xml"} and \code{"html"} get \code{XHTML} text with metadata. \code{"jsonRecursive"} gets \code{XHTML} text and \code{json} metadata. \code{c("jsonRecursive","text")} or \code{c("J","t")} gets plain text and \code{json} metadata. See the 'Output Details' section.
#' @param output_dir Optional directory path to save the converted files in. Tika may overwrite files so an empty directory is best. See the 'Output Details' section before using.
#' @param java Optional command to invoke Java. For example, it could be to the full path of a particular Java version. See the Configuration section below.
#' @param jar Optional alternative path to a \code{tika-app-X.XX.jar}. Useful if this package becomes out of date.
#' @param threads Integer of the number of file consumer threads Tika uses. Defaults to 1.
#' @param args Optional character vector of additional arguments for Tika, that are not yet implemented in this R interface, in the pattern of \code{c('-arg1','setting1','-arg2','setting2')}. Currently settable arguments include \code{-timeoutThresholdMillis} (Number of milliseconds allowed to a parse before the process is killed and restarted), \code{-maxRestarts} (Maximum number of times the watchdog process will restart the child process), \code{-includeFilePat} (Regular expression to determine which files to process, e.g. \code{"(?i)\.pdf"}), \code{-excludeFilePat}, and \code{-maxFileSizeBytes}. These are documented in the .jar --help command.
#' @param quiet Logical if Tika command line messages and errors are to be supressed. Defaults to TRUE.
#' @param cleanup Logical to clean up temporary files after running the command, which can accumulate. They are in \code{tempdir()}. These files normally be removed at the end of the R session anyhow.
#' @param lib.loc Optional character vector describing the library path(s) containing \code{curl}, \code{data.table} or \code{sys} packages. Normally, it's best to install the packages and leave this parameter alone. The parameter is included mainly for package testing.
#' @return A character vector in the same order as the input, and the same lenth. Unprocessed files are NA. See the Output Details section below.
#' @examples
#' #' #extract text 
#' input= 'https://cran.r-project.org/doc/manuals/r-release/R-data.pdf'
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
#' If an input file did not exist, could not be downloaded, was a directory, or Tika could not process it, the result will be an NA for that file. This should not disrupt the processing of other files in the input, although there may be warnings if it was Tika's fault.
#' 
#' By default, \code{output = "text"} and this produces plain text with no metadata. Some formatting is preserved using tabs, newlines and spaces.
#' 
#' Setting \code{output} to either \code{"xml"} or the shortcut \code{"x"} will produce a strict form of \code{HTML} known as \code{XHTML}, with metadata in the \code{head} node and formatted text in the \code{body}.
#' Content retains more formatting with \code{"xml"}. For example, a Word or Excel table will become a HTML \code{table}, with table data as text in \code{td} elements. The \code{"html"} option and its shortcut \code{"h"} seem to produce the same result as \code{"xml"}.
#' Parse XHTML output with \code{xml2::read_html}. 
#' 
#' Setting \code{output} to \code{"jsonRecursive"} or its shortcut \code{"J"} produces a tree structure in `json`. Metadata fields are at the top level. The \code{XHTML} or plain text will be found in the \code{X-TIKA:content} field. By default the text is \code{XHTML}. This can be changed to plain text like this: \code{output=c("jsonRecursive","text")} or \code{output=c("J","t")}. This syntax is meant to mirror Tika's. Parse \code{json} with \code{jsonlite::fromJSON}. 
#'
#'  If \code{output_dir} is specified, then the converted files will also be saved to this directory. It's best to use an empty directory because Tika may overwrite existing files. Tika seems to add an extra file extension to each file to reduce the chance, but it's still best to use an empty directory. The file locations within the \code{output_dir} maintain the same general path structure as the input files. Downloaded files have a path similar to the `tempdir()` that R uses. The original paths are now relative to \code{output_dir}.  Files are appended with \code{.txt} for the default plain text, but can be \code{.json}, \code{.xml}, or \code{.html} depending on the \code{output} setting. One way to get a list of the processed files is to use \code{list.files} with \code{recursive=TRUE}.
#'  If \code{output_dir} is not specified, files are saved to a volatile temp directory named by \code{tmpdir()} and will be deleted when R shuts down. If this function will be run on very large batches repeatedly, these temporary files can be cleaned up every time by adding 
#'  \code{cleanup=TRUE}.
#' @section Background:
#' Tika is a foundational library for several Apache projects such as the Apache Solr search engine. It has been in development since at least 2007. The most efficient way I've found to process many thousands of documents is Tika's 'batch' mode, which is the only mode used in `rtika`. There are potentially more things that can be done with this package, given enough time and attention, because Apache Tika includes many libraries and methods in its .jar file. The source is available at: \url{https://tika.apache.org/}. 
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
#' 
#' The \code{curl} package downloads files quickly, if the user includes urls in the \code{input}. In testing, \code{curl} is required on Windows to avoid errors, and more work may still be needed to make Windows parse reliably. 

tika <- function(input, output=c('text','jsonRecursive','xml','html')[1], output_dir="", java = 'java',jar=system.file("java", "tika-app-1.17.jar", package = "rtika"), threads=1,args=character(), quiet=TRUE,cleanup=FALSE,lib.loc=.libPaths()) {
  # Special thanks to Hadley for the nice git tutorial at: http://r-pkgs.had.co.nz/git.html
  # devtools::build_vignettes()
  # system('R CMD Rd2pdf ~/rtika')
  # parameter sanity check
  stopifnot( 
    class(input)=='character'
   , length(input) > 0
   , class(output)=='character'
   , length(output) > 0
   , length(output) <= 2
   , class(output_dir) == 'character'
   , length(output_dir) == 1
   , class(java) == 'character'
   , length(java) == 1
   , class(jar) == 'character'
   , length(jar) == 1
   , class(threads) %in% c('integer','numeric')
   , class(args) == 'character'
   , class(quiet)== 'logical'
   , class(cleanup) == 'logical'
   , class(lib.loc) == 'character'
    ) 
 
    root = normalizePath('/',winslash = "/") 
    
    # the output directory stores tika's processed files. If it doesn't exist, create one in the temp directory
    if(output_dir==""){
      output_dir = tempfile('rtika_dir')
      dir.create(output_dir)
    } else {
      # if an output directory is provided, check it exists. 
      output_dir = normalizePath(output_dir, mustWork=TRUE, winslash = '/')
      # Must be very careful writing to any directory outside of temp directory. Idea here it to check its not the root directory
      if(output_dir==root){
        stop('Output directory cannot be the same as the root, because it is usually unsafe (e.g. Tika may overwrite files or create unwanted directories).')
      }
    }

  # output will be character vector the same length as input, with initial NAs ...
  out = character(length(input))
  failure = as.character(NA)
  out[out=='']<- failure
 
  # download files to R's temp directory
  toDownload = grep('^(http[s]?:/|ftp:/|file:/)',input, ignore.case=TRUE)
  if(length(toDownload)>0){
    if(requireNamespace('curl',quietly = TRUE,lib.loc=lib.loc)){
      .rtika_fetch = function(url){ 
        ret = tempfile('rtika_file') ; 
        req = curl::curl_fetch_disk(url,ret) 
        if(req$status_code!=200){
          warning('Could not download with curl::curl_fetch_disk: ', url)
          return(as.character(NA))
        }
        # TODO: consider adding file affix.
        # OS X and ubuntu content-type is recorded in file extended attributes. Check with cmd: file --mime-type -b rtika_file*
        # However, on windows, neither download.file and curl record content type as an extended attribute or file type affix
        # typically, content0type is in header. It may or may not map to file type affix of file on internet.
        # headers = parse_headers(req$headers)
        # ctype <- headers[grepl("^content-type", headers, ignore.case = TRUE)]
        # https://github.com/jeroen/curl/blob/974495cd4880771a934b486530d11dd82aa743dd/examples/sitemap.R
        # can map mime type to file extions:
        # * https://raw.githubusercontent.com/apache/tika/master/tika-core/src/main/resources/org/apache/tika/mime/tika-mimetypes.xml
        # * ubuntu has a list in: /etc/mime.types
        #  header content-type is more reliable that path affix in URL? 
        # this is often missing or wrong (e.g. .php, .cfm typically produce .html)
        #       # path  = xml2::url_parse(url)$path
        #       # regex pattern based on known extensions of Tika. Note that extension like .php, .cfm producing .html or other formats may or may not be an issue with tika. If it is, its worth using your own downloader. THis is just a convenience downloader.
        #        # xml = xml2::read_xml('https://raw.githubusercontent.com/apache/tika/master/tika-core/src/main/resources/org/apache/tika/mime/tika-mimetypes.xml')
        #       # ext = sort(xml2::xml_attr(xml_find_all(xml,'//glob'),'pattern'))
        #       # max(nchar(ext[grepl('*.', ext,fixed=T)])-1) # 12
        #       # sort(unique(unlist(strsplit(ext[grepl('*.', ext,fixed=T)],''))))
        #       # paste( sort(unique(unlist(strsplit(ext[grepl('*.', ext,fixed=T)],'')))) , collapse = ' ') 
        #       # ext = tolower(regmatches(path, regexpr('\\.[A-Za-z0-9\\-_+]{1,12}$',path)))
        # if path affix in URL does not match declared file type in headers, use headers?

        return(ret)
      }
    } else {
      if(.Platform$OS.type=='windows'){
        warning("It's recommended to install the 'curl' package on Windows because the built in utils::download.file was not working.")
      }
      .rtika_fetch = function(url){ 
        ret = tempfile('rtika_file') ; 
        req = tryCatch( utils::download.file(url,ret, method='libcurl') , error=function(e) { return(1)}) ;
        if(req != 0){
          warning('Could not download with utils::download.file: ', url)
          return(as.character(NA))
        }
        return(ret)
      }
    }
    #add downloads to input (if not found, rtika_download produces NAs)
    urls = input[toDownload]
    tempfiles =  sapply(urls, .rtika_fetch)
    input[toDownload]<- tempfiles
  }
  
  # TODO: consider customizing config file for fine grained control over parsers?, see: https://tika.apache.org/1.17/configuring.html

  # check if the un-normalized input files exist, are not directories, and are not NA paths
  file_exists = !is.na(input) & file.exists(input) & !dir.exists(input)
  if(!any(file_exists)) {
     warning('No files could be found.')
      return(out) 
  }
      
  inputFiles = normalizePath(input[file_exists] , winslash = '/')
 
  # Tika expects files to be relative to root
  # NB: These paths will be READ, NOT written to! 
  inputFiles = sub(root,'',inputFiles, fixed=TRUE)
  
  # name a delimited file list that will be passed to Tika for reading. File paths containing both commas and quote characters appear to work with the settings below.
  fileList = tempfile('rtika_file')
  if(requireNamespace('data.table',quietly = TRUE,lib.loc=lib.loc)){
    data.table::fwrite( data.table::data.table(inputFiles) ,fileList ,row.names = FALSE,col.names = FALSE, sep=',', quote=FALSE )
  } else {
    utils::write.table( inputFiles ,fileList ,row.names = FALSE,col.names = FALSE, sep=',', quote=FALSE) 
  }
  # after the file created, make sure it exists
  fileList = normalizePath(fileList , mustWork=TRUE, winslash = '/') 
  
 
 
  output_flag= character()
  output_flag = ifelse('jsonRecursive' %in% output|'J' %in% output,'-J', output_flag) # goes first
  output_flag = c(output_flag, ifelse('text' %in% output|'t' %in% output,'-t',NA) )
  output_flag = c(output_flag, ifelse('xml' %in% output|'x' %in% output,'-x',NA) )
  output_flag = c(output_flag, ifelse('html' %in% output|'h' %in% output,'-h',NA) )
  output_flag = as.character(stats::na.omit(output_flag ))

  if(.Platform$OS.type=='windows'){
    # windows requires quoting for paths, but others run into problems with default quoting on paths
    java_args = c('-jar',shQuote(jar),'-numConsumers', as.integer(threads), args, output_flag,'-i',shQuote(root),'-o',shQuote(output_dir),'-fileList',shQuote(fileList))
  } else {
    java_args = c('-jar',jar,'-numConsumers', as.integer(threads), args, output_flag,'-i',root,'-o',output_dir,'-fileList',fileList)
  }

  # Compared to system2, sys is somehow much quicker when making the call to java. 
  # TODO: catch java errors if possible
  if(requireNamespace('sys',quietly = TRUE,lib.loc=lib.loc)){
    sys::exec_wait(cmd=java[1] , args=java_args ,std_out=!quiet, std_err=!quiet )
  } else {
    system2(command=java[1] , args=java_args ,stdout=!quiet, stderr=!quiet )
  }
  
  output_file_affix = character()
  output_file_affix = ifelse('text' %in% output|'t' %in% output,'.txt',output_file_affix)
  output_file_affix = ifelse('xml' %in% output|'x' %in% output,'.xml',output_file_affix)
  output_file_affix = ifelse('html' %in% output|'h' %in% output,'.html',output_file_affix)
  output_file_affix = ifelse('jsonRecursive' %in% output|'J' %in% output,'.json',output_file_affix)
  
  # like a vectorized readChar
  .rtika_readFile <- function(path){
    bytes =  file.size(path)
   ifelse(!is.na(bytes), mapply(readChar,con=path,nchars=bytes,useBytes=TRUE),as.character(NA)) 
  }
  
  #Clean & check with normalizePath, with warnings if not processed.
  output_files = normalizePath(file.path(output_dir,paste0(inputFiles,output_file_affix)), winslash = '/') 
 
  out[file_exists] <- .rtika_readFile(output_files)

  # remove tempfiles if instructed to.
  if(cleanup){
    trash_file = file.path(tempdir(),list.files(tempdir(),pattern='^rtika_file'))
    if(length(trash_file)>0){
      tmp= file.remove(trash_file)
    }
    
    trash_dir = file.path(tempdir(),list.files(tempdir(),pattern='^rtika_dir'))
    if(length(trash_dir)>0) { # paranoid.
      # if(.Platform$OS.type=='windows'){
      #   tmp=  unlink( trash_dir, recursive =TRUE, force=TRUE) # does not seem to work unless force=TRUE on windows.
      # } else {
      tmp=  unlink( trash_dir, recursive =TRUE) 
      # }
    }
  }
  
  # UTF-8 is the preferred output format.
  # While early Tika versions seemed to output UTF-16 from Java's SAX processor, it may be UTF-8 now. The XML output now declared UTF-8. 
  out =  enc2utf8(out)
  
  return(out)
  
}



