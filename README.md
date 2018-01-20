
rtika
=====

***An R interface to Apache Tika, which extracts text and metadata from almost any file.***

[![Travis-CI Build Status](https://travis-ci.org/predict-r/rtika.svg?branch=master)](https://travis-ci.org/predict-r/rtika)

According to Wikipedia: "Apache Tika is a content detection and analysis framework, written in Java, stewarded at the Apache Software Foundation. It detects and extracts metadata and text from over a thousand different file types, and as well as providing a Java library, has server and command-line editions suitable for use from other programming languages .... For most of the more common and popular formats, Tika then provides content extraction, metadata extraction and language identification capabilities." (Accessed Jan 18, 2018. See <https://en.wikipedia.org/wiki/Apache_Tika>.)

Installation
------------

For `rtika` to work, you need at least `Java 7` or `OpenJDK 1.7`. To check, you can run the command `java -version` from a terminal. If it's not there, try <http://openjdk.java.net/install/> or <https://www.java.com/en/download/help/download_options.xml>.

Next, install the `rtika` package.

``` r
# devtools allows installation directly from github. if devtools is not installed, install it.
if(!library('devtools',logical.return=TRUE,quietly=TRUE)){ 
    install.packages('devtools', repos='https://cloud.r-project.org')
  }
# Install rtika from github
if(!library('rtika',logical.return=TRUE,quietly=TRUE)){
    devtools::install_github('predict-r/rtika') 
  } 
library('rtika')
```

Extract Plain Text
------------------

Put some documents to a folder. Include almost any file type, such as `.pdf`, `.doc`, `.docx`, `.rtf`, `.ppt`, or a mix. Relax, because Tika will handle it.

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

The `text` will be a character vector, in the order of `list.files(dir)`. Display a snippet using `cat`.

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
------------

You can get metadata about a document by chosing json as the output format. Other options that get metadata are `xml` or `html`. A side effect is more document structure is retained, such as table cells.

``` r
require('jsonlite')
json = tika(dir,'J') # 'J' is a shortcut for 'jsonRecursive'
metadata = fromJSON(json[1])
```

Overview of the metadata structure.

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
     $ X-TIKA:parse_time_millis                   : chr "1000"
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

Similar Packages
----------------

In March 2012, I created a repository on `r-forge` called `r-tika` (See: <https://r-forge.r-project.org/projects/r-tika/>). While no code was publicly released, my initial codebase used low-level functions from the `rJava` package to interface with the Tika library. I halted development after discovering that the Tika command line interface (CLI) served my purposes.

In September 2017, user *kyusque* released `tikaR`, which uses the `rJava` package to interact with Tika (See: <https://github.com/kyusque/tikaR>). As of writing, it provided a `xml` parser and metadata extraction.

With `rtika`, I chose to interface with the Tika CLI and its 'batch processor' tool. Much of the batch processor is implemented in Tika 1.17 (See: <https://wiki.apache.org/tika/TikaBatchOverview>). The Tika batch processor has good efficiency when processing tens of thousands of documents, is not too slow for a single document, and handles errors gracefully. Further, connecting `R` to the Tika CLI batch processor is relatively easy to maintain, because the `R` code is simple. I anticipate that various researchers will need plain text output, while others want json output. These are implemented in the CLI and hence in `rtika` (although apparently not in `tikaR`). Multiple theads are supported in both the CLI and `rtika`. The `rtika` package anticipates future features with the `args` attribute of the `tika` funtion, that allows access to the Tika CLI. Another motivation was that `rJava` had once been difficult to get working on Ubuntu and CentOS, especially around when Java was not open sourced, although that probably is no longer the case.
