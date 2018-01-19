#' R Interface to Apache Tika 
#' 
#' Get plain text from many, many types of documents. Apache Tika parses more than a thousand types, which is incredible but true. 
#' Optionally, it can return metadata in \code{json}, \code{xml}, or \code{html}. For example, it will try to identify the \code{Content-Type} from pictures, videos, audio, code, and textual documents when \code{output="jsonRecursive"}, \code{output="xml"}, or \code{output="html"}.
#' It automatically detects and parses several versions of Word, OpenOffice, rtf, iWorks, WordPerfect, pdf, epub, and more. It detects the character encodings of plain text files. It gets Exif from jpeg and tiff. It parses email mail boxes as well. See all the supported input formats here: \url{https://tika.apache.org/1.17/formats.html}.
#' 
#' @param inputDir Directory where the files to be processed are. Each file in the directory will be read and analyzed but not changed.
#' @param output Optional text format of the output. By default, \code{output = "text"}. That produces plain text without metadata. Use \code{output="jsonRecursive"} or \code{output="J"} to output metadata and content from the file and any embedded files, which can be parsed with the \code{jsonlite} package. Setting it to \code{output="xml"} or \code{output="x"} means the result of each file is XHTML, that can be parsed with other tools like the \code{XML} or \code{xml2} packages. The \code{output = "html"} or \code{output = "h"} is HTML, similar to XHTML. 
#' @param outputDir Optional directory path to save the result as files, as a side effect. Otherwise they are saved to a tmp directory R creates at startup and will be taken care of when R shuts down. Files are \code{.txt} by default, but can be \code{.json}, \code{.xml}, or \code{.html} depending on the \code{output} setting.
#' @param nchars Optional single integer specifying the maximum number of characters returned for each document, returned by the \code{readChar} function. The default is 1e+07. Higher numbers may be needed for exceptionally large files. There appears to be no advantage to lowering this, and no efficiency loss to raising it.
#' @param java Optional alternative command to invoke Java. For example, it could be changed to the full path of a particular Java version. See the Configuration section below.
#' @param jar Optional alternative path to the \code{tika-app-X.XX.jar}. Useful if the included version becomes out of date.
#' @param threads Integer of the number of file consumer threads Tika uses. Defaults to 1.
#' @param options Optional character vector of additional options for Tika not yet implemented in R, in the pattern of \code{c('-option1','setting1','-option2','setting2')}. Settable options include \code{-timeoutThresholdMillis} (Number of milliseconds allowed to a parse before the process is killed and restarted), \code{-maxRestarts} (Maximum number of times the watchdog process will restart the child process), \code{-includeFilePat} (Regular expression to determine which files to process, e.g. "(?i)\.pdf"), \code{-excludeFilePat}, and \code{-maxFileSizeBytes}. These are documented in the .jar --help command.
#' @return A character vector, where each string corresponds to a file in the \code{inputDir}. The order is the same as that produced by \code{list.files(inputDir)}. If a file is not processed, the result will be NA. Also see the \code{output} options, above.
#' @examples
#' # download file to some accessible directory
#' dir = file.path(getwd(),'tika-example'); dir.create(dir); 
#' download.file('https://cran.r-project.org/doc/manuals/r-release/R-data.pdf',file.path(dir,'R-data.pdf'))
#'
#' #extract text 
#' text = tika(dir)
#' cat(substr(text,1,2000))
#' 
#' #get metadata
#' require('jsonlite')
#' json = tika(dir,'jsonRecursive')
#' 
#' metadata = fromJSON(json[1])
#' str(metadata) #data.frame of metadata
#' 
#' metadata$'Content-Type' # [1] "application/pdf"
#' metadata$producer # [1] "pdfTeX-1.40.18"
#' metadata$'Creation-Date' # [1] "2017-11-30T13:39:02Z"
#' # unlink(dir, recursive=TRUE) #remove the downloaded file
#' @section Background:
#' Tika is a foundational library for several Apache projects, such as the Apache Solr search engine. This R interface produces a big payoff for R users. The most efficient way I've found to process tens of thousands of documents is Tika's 'batch' mode, which is used. There is more to do, given enough time and attention, because Apache Tika includes many other libraries and methods. The source is available at: \url{https://tika.apache.org/}. 
#' @section Configuration:
#' The first version of this package includes the \code{tika-app-X.XX.jar}. This jar works with Java 7. Tika in mid-2018 need Java 8. By default, this R package internally invokes Java by calling the \code{java} command from the command line. To change this, set the \code{java} attribute to call it another way (e.g. the full path to the location of a particular version of java).

tika <- function(inputDir, output=c('text','jsonRecursive','xml','html')[1], outputDir="", nchars=1e+07, java = 'java',jar=system.file("java", "tika-app-1.17.jar", package = "tika"), threads=as.integer(1),options=character()) {
  # generate pdf with system('R CMD Rd2pdf ~/rtika')
  # java will require the full path
  inputDir = tools::file_path_as_absolute(inputDir)
 
  # check if the input directory exists 
  if(!file.exists(inputDir)) stop('inputDir does not exist')
  
  # make sure its a directory
  inputInfo = file.info(inputDir)
  if(!inputInfo$isdir) stop('inputDir is not a directory')
  
  # if the output directory argument is missing, create one in the tmp folder created at R startup. R will manage the memory and there should be no need to delete files
  if(missing(outputDir)||outputDir==""){
    #each time we will create an empty folder within the tmp folder.
    outputDir = file.path(tempdir(),'tika-out')
    if(file.exists(outputDir)){
      #unlink means delete. Recursive is needed to remove a directory.
      unlink(outputDir,recursive= TRUE)
    }
    dir.create(outputDir)
  } else {
    # if an output directory is provided, check it exists.
    outputDir = tools::file_path_as_absolute(outputDir)
    if(!file.exists(outputDir)) stop('outputDir does not exist')
  }
  
  # keep track of which file names were input, so only these are outputted
  inputFiles = list.files(inputDir)
  
  # get the full path to the jar in the java folder within the package.
 # jar = system.file("java", "tika-app-1.17.jar", package = "tika")
 
  # I recall that only sys ran without problems. The -t is the text flag, otherwise its xml with metadata. '-J' is documented to be a recursive in memory version and appears to output json.
  # The java is either the full path to java or the commandline shortcut
  output_flag = '-t'
  output_flag = ifelse(output=='jsonRecursive'|output=='J','-J',output_flag)
  output_flag = ifelse(output=='xml'|output=='x','-x',output_flag)
  output_flag = ifelse(output=='html'|output=='h','-h',output_flag)
  
  sys::exec_wait(cmd=java[1] , args=c('-jar',jar,'-numConsumers', as.integer(threads), options, output_flag,'-i',inputDir,'-o',outputDir) )
  
  # prepare the output character vector
  out = character()
  
  output_file_affix = '.txt'
  output_file_affix = ifelse(output=='jsonRecursive'|output=='J','.json',output_file_affix)
  output_file_affix = ifelse(output=='xml'|output=='x','.xml',output_file_affix)
  output_file_affix = ifelse(output=='html'|output=='h','.html',output_file_affix)
  
  # for each file name
  for(f in inputFiles){
    #get the full path
    fp = file.path(outputDir,paste0(f,output_file_affix))
    if(file.exists(fp)){
      this = readChar(fp,nchars=nchars[1])
    } else {
      this = as.character(NA)
    }
    out = c(out, this)
  }
  
  
  return(out)
}
