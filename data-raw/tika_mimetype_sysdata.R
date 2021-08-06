tika_mimetype_sysdata <- function(){
  require('xml2')
  #  the media types in tika-mimetypes.xml represent all of Tika’s knowledge about
  # media types.

  url <-  url('https://raw.githubusercontent.com/apache/tika/master/tika-core/src/main/resources/org/apache/tika/mime/tika-mimetypes.xml')
  # get xml object
  # don't worry about namespace errors, with prifix tika not being defined.
  # in Shared MIME-info Database specification 
  download <-  xml2::read_xml(url)
  
  # extract mime-type nodes
  mimetypes  <-  xml2::xml_find_all(download, '//mime-type')
  
  # get type attribute 
  type <-  xml2::xml_attr(mimetypes, 'type')
  
  # for MIME, the name of a media type consists of:
  # type/subtype type definition and an optional set of name=value parameters
  # in US-ASCII
  # tika_fetch matches on lowercase
  # see: https://www.w3.org/Protocols/rfc1341/4_Content-Type.html
  type <-  tolower(type)
  
  # extract first valid file extension that is in 'pattern' field
  file_extension <-  xml2::xml_attr(xml2::xml_find_first(mimetypes, './/glob'), 'pattern')
  
  # make data frame
  tika_mimetype <-  data.frame(type, file_extension, stringsAsFactors = FALSE)
  
  # remove some types
  # some don't have a file extension.
  tika_mimetype <- tika_mimetype[!is.na(file_extension), ]
  
  # out of 1540+ types, one has a complex pattern.
  # the isatab type depend on first letters of file name starting with particular pattern, like s_, i_ or a_
  # remove this for now, until tika_fetch can handle complex matching.
  # it otherwise might cause confusion.
  tika_mimetype <-  tika_mimetype[!grepl('^[a-z]_\\*', tika_mimetype$file_extension), ]
  
  # two others use complex MIME parameters after the type/subtype
  # Mime allows paraemters such as format=
 
  # this happens with two types, onenote and dita only
  # ignore these cases until tika_fetch has complex parsing of content types
  tika_mimetype <-  tika_mimetype[!grepl(';.*', tika_mimetype$type), ]
  
  # clean up * in glob matcher.
  tika_mimetype$file_extension <-  sub('^\\s*\\*', '', tika_mimetype$file_extension)
  
  # this still leaves at least 839 mime types
  cat('number of MIME types: ',
      nrow(tika_mimetype), '\n')
    cat('max char length of MIME types with file extension to use: ',
        max(nchar(tika_mimetype$type)), '\n')
 
  # this was first setup with devtools:
  # devtools::use_data(tika_mimetype, internal=TRUE, overwrite=TRUE)
  
  # save over the R/sysdata.rda in the package
  save(tika_mimetype, file = "R/sysdata.rda")
}
