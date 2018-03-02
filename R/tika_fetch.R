
#' Fetch Files and Record Content-Type in the File Extension
#'
#' On the Internet, Content-Type information is mainly communicated via the server's headers. 
#' This is an issue if a file is saved to disk without examining the headers.
#' The file can have a missing or incorrect file extension.
#' For example, a URL ending in a slash (\code{/}) can produce file with the Content-Type of  \code{text/html}.
#' The same URL might also produce a \code{image/jpeg} or \code{application/pdf} file.
#' URLs ending in \code{.php}, \code{.cfm} can produce any Content-Type.
#' The downloaded file will lose the server's declared Content-Type unless its appended as a file extension.
#' tika_fetch gets a file from the URL, examines the server headers, 
#' and appends the matching file extension
#' from Tika's database.
#' 
#' @param urls Character vector of one or more URLs to be downloaded. 
#' @param download_dir Character vector of length one describing the path to the directory to save the results.
#' @param ssl_verifypeer Logical, with a default of TRUE. Some server SSL certificates might not be recognized by the host system, and in these rare cases the user can ignore that if they know why.
#' @param retries Integer of the number of times to retry each url after a failure to download.
#' @param quiet Logical if download warnings should be printed. Defaults to FALSE.
#' @return Character vector of the same length and order as input with the paths describing the locations of the downloaded files. Errors are returned as NA.
#' @examples
#' \donttest{
#' paths = tika_fetch('https://tika.apache.org/')
#' # a unique file name with .html appended to it
#' }
#' @export
tika_fetch <- function(urls, download_dir = tempdir(), ssl_verifypeer=TRUE, retries=1, quiet=TRUE){
  
  download_dir <- normalizePath(download_dir, winslash = "/")
  
  # tika/tika-core/src/main/java/org/apache/tika/io/TikaInputStream.java
  # https://developer.mozilla.org/en-US/docs/Web/Security/Securing_your_site/Configuring_server_MIME_types
  # https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.2
  # https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#2xx_Success
  
  # get output vector to be length of input 
  out <- character(length(urls))
  failure <- as.character(NA)
  out[out == ""] <- failure
  
  for(i in seq_along(urls)){
    
    # file_name must be available
    file_name <- tempfile("rtika_file", tmpdir=download_dir)
    
    # first try for this url
    this_try = 1
    
    # while tries are less than default retries
    while(this_try <= retries){
      
      # if we must verify ssl works
      if(ssl_verifypeer){
        req <- tryCatch(curl::curl_fetch_disk(url=urls[i], path=file_name), 
                        error = function(e) {
                          return(list(status_code = 418))
                          })
      } else {
        # else will ignore ssl
        handle = curl::new_handle()
        curl::handle_setopt(handle, ssl_verifypeer = 0L)
        req <- tryCatch(curl::curl_fetch_disk(url=urls[i], path=file_name, handle=handle), 
                        error = function(e) {
                          return(list(status_code = 418))
                        })
        }
      
      # count this as an attempt
      this_try = this_try + 1
     
      #  these success headers that indicate response data was sent back.
      if (!req$status_code %in% c(200,203,206,207,226)) {
        if(!quiet){
            if(this_try<=retries){
              warning("Retrying::curl_fetch_disk: ", urls[i])
            } else {
              warning("Could not download with curl::curl_fetch_disk: ", urls[i])
            }
        }
        next()
      }
    
    # put headers into character vector
    headers <- curl::parse_headers(req$headers)
    
    # find any lines that have content type declared
    ctype <- headers[grepl("^content-type", headers, ignore.case = TRUE)]
    
    # if there are any content-type headers
    if(length(ctype)>0){
      # use first line in case multiple lines from server.
      ctype = ctype[1]
      
      #remove anything before and after first semicolon
      ctype = sub('\\s*;.*$','',ctype)
      
      #trim end if last did not match
      ctype = sub('\\s*$','',ctype)
      
      #remove first part of line.
      ctype = sub('^Content-Type:\\s*','',ctype, ignore.case=TRUE)
      
      # make lowercase for case insensitive match with lowercase tika_mimetype$type
      ctype = tolower(ctype)
      # max length of known types is 73. 
      # tika_mimetypes is loaded in this package namespace
      # it is found in sysdata.rda
      
      if(nchar(ctype>0) & nchar(ctype) < 74 ){
        found = match(ctype, tika_mimetype$type)
        if(length(found)>0){
          
          # shouldn't be multiple, but get first 
          found = found[1]
          
          file_name_with_extension = paste0(file_name,
                                            tika_mimetype[found,][1,]$file_extension)
          
          #renaming might not be possible on some systems
          renamed = file.rename(file_name,file_name_with_extension)
            if(renamed) {
              file_name <- file_name_with_extension
            }
          }
       }
      }
      out[i] <- file_name
    }
  }
  
  return(out)
}