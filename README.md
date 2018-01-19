
What is this?
=============

Apache Tika gives one the power to take a directory filled with almost any type of file and extract the text and metadata from the files. This is an R Interface to Tika.

According to Wikipedia: "Apache Tika is a content detection and analysis framework, written in Java, stewarded at the Apache Software Foundation. It detects and extracts metadata and text from over a thousand different file types, and as well as providing a Java library, has server and command-line editions suitable for use from other programming languages .... For most of the more common and popular formats, Tika then provides content extraction, metadata extraction and language identification capabilities." (Accessed Jan 18, 2018. See <https://en.wikipedia.org/wiki/Apache_Tika>.)

Once you have Java 7 installed on your system, you are ready to install and load this R package, which includes the Tika program. You do not need the 'rJava' package.

``` r
# if devtools is not installed, install.
if(!library('devtools',logical.return=TRUE)){ install.packages('devtools', repos='https://cloud.r-project.org') }
# if rtika is not installed, install.
if(!library('rtika',logical.return=TRUE)){ devtools::install_github('predict-r/rtika') } 
```

Extract Plain Text
==================

Put some documents to a folder. Put in almost any type, such as .pdf, .doc, .docx, .rtf, or an arbitrary mix of those. Relax, because Tika will handle it.

``` r
dir = file.path(getwd(),'tika-example'); # create a directory called 'tika-example' in R's working directory
dir.create(dir); 
url = 'https://cran.r-project.org/doc/manuals/r-release/R-data.pdf'
download.file(url, file.path(dir,'R-data.pdf')) # download a .pdf 
```

Extract the plain text using Tika.

``` r
text = tika(dir) # magic happens
```

Display a snippet of the extracted text using con**cat**enate.

``` r
cat(substr(text[1],45,450)) # sub-string of the text
```


    R Data Import/Export
    Version 3.4.3 (2017-11-30)

    R Core Team



    This manual is for R, version 3.4.3 (2017-11-30).

    Copyright c© 2000–2016 R Core Team
    Permission is granted to make and distribute verbatim copies of this manual provided
    the copyright notice and this permission notice are preserved on all copies.

    Permission is granted to copy and distribute modified versions of this manual under
    the cond

Get Metadata
============

You can get metadata about a document by chosing json as the output format. Other options that get metadata are 'xml' or 'html'.

``` r
require('jsonlite')
json = tika(dir,'J') # 'J' is a shortcut for 'jsonRecursive'
metadata = fromJSON(json[1])
```

View the structure of it.

``` r
str(metadata) #data.frame of metadata
```

    'data.frame':   1 obs. of  41 variables:
     $ Content-Length                             : chr "309939"
     $ Content-Type                               : chr "application/pdf"
     $ Creation-Date                              : chr "2017-11-30T13:39:02Z"
     $ Last-Modified                              : chr "2017-11-30T13:39:02Z"
     $ Last-Save-Date                             : chr "2017-11-30T13:39:02Z"
     $ PTEX.Fullbanner                            : chr "This is pdfTeX, Version 3.14159265-2.6-1.40.18 (TeX Live 2017/Debian) kpathsea version 6.2.3"
     $ X-Parsed-By                                :List of 1
      ..$ : chr  "org.apache.tika.parser.DefaultParser" "org.apache.tika.parser.pdf.PDFParser"
     $ X-TIKA:content                             : chr "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n<meta name=\"date\" content=\"2017-11-30T13:39:02Z\" />\"| __truncated__
     $ X-TIKA:digest:MD5                          : chr "3f1b649a4ec70aaa4c2dad4eade8b430"
     $ X-TIKA:parse_time_millis                   : chr "1013"
     $ access_permission:assemble_document        : chr "true"
     $ access_permission:can_modify               : chr "true"
     $ access_permission:can_print                : chr "true"
     $ access_permission:can_print_degraded       : chr "true"
     $ access_permission:extract_content          : chr "true"
     $ access_permission:extract_for_accessibility: chr "true"
     $ access_permission:fill_in_form             : chr "true"
     $ access_permission:modify_annotations       : chr "true"
     $ created                                    : chr "Thu Nov 30 05:39:02 PST 2017"
     $ date                                       : chr "2017-11-30T13:39:02Z"
     $ dc:format                                  : chr "application/pdf; version=1.5"
     $ dcterms:created                            : chr "2017-11-30T13:39:02Z"
     $ dcterms:modified                           : chr "2017-11-30T13:39:02Z"
     $ meta:creation-date                         : chr "2017-11-30T13:39:02Z"
     $ meta:save-date                             : chr "2017-11-30T13:39:02Z"
     $ modified                                   : chr "2017-11-30T13:39:02Z"
     $ pdf:PDFVersion                             : chr "1.5"
     $ pdf:docinfo:created                        : chr "2017-11-30T13:39:02Z"
     $ pdf:docinfo:creator_tool                   : chr "TeX"
     $ pdf:docinfo:custom:PTEX.Fullbanner         : chr "This is pdfTeX, Version 3.14159265-2.6-1.40.18 (TeX Live 2017/Debian) kpathsea version 6.2.3"
     $ pdf:docinfo:modified                       : chr "2017-11-30T13:39:02Z"
     $ pdf:docinfo:producer                       : chr "pdfTeX-1.40.18"
     $ pdf:docinfo:trapped                        : chr "False"
     $ pdf:encrypted                              : chr "false"
     $ producer                                   : chr "pdfTeX-1.40.18"
     $ resourceName                               : chr "R-data.pdf"
     $ tika:file_ext                              : chr "pdf"
     $ tika_batch_fs:relative_path                : chr "R-data.pdf"
     $ trapped                                    : chr "False"
     $ xmp:CreatorTool                            : chr "TeX"
     $ xmpTPg:NPages                              : chr "37"
