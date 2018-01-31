
rtika
=====

***Extract text or metadata from over a thousand file types.***

[![Travis-CI Build Status](https://travis-ci.org/predict-r/rtika.svg?branch=master)](https://travis-ci.org/predict-r/rtika) [![Coverage status](https://codecov.io/gh/predict-r/rtika/branch/master/graph/badge.svg)](https://codecov.io/github/predict-r/rtika?branch=master)

> Apache Tika is a content detection and analysis framework, written in Java, stewarded at the Apache Software Foundation. It detects and extracts metadata and text from over a thousand different file types, and as well as providing a Java library, has server and command-line editions suitable for use from other programming languages ...

> For most of the more common and popular formats, Tika then provides content extraction, metadata extraction and language identification capabilities. (Accessed Jan 18, 2018. See <https://en.wikipedia.org/wiki/Apache_Tika>.)

This R interface includes the Tika software.

Installation
------------

You only need `Java 7` or `OpenJDK 1.7`. Higher versions also work. To check, run the command `java -version` from a terminal. Get Java installation tips at <http://openjdk.java.net/install/> or <https://www.java.com/en/download/help/download_options.xml>.

On Windows, the `curl` package is suggested if there are documents to process on a remote server.

Next, install the `rtika` package from github.com. It has no other dependencies.

``` r
# devtools simplifies installation from Github.
if(!requireNamespace('devtools')){ install.packages('devtools', repos='https://cloud.r-project.org') }
# Install rtika from github
if(!requireNamespace('rtika')){ devtools::install_github('predict-r/rtika') } 
library('rtika')
```

Extract Plain Text
------------------

Describe the paths to documents that contain text, such as `.pdf`, `.doc`, `.docx`, `.rtf`, `.ppt`, or a mix. Then, Tika will identify the file format, parse it, and return a plain text rendition.

``` r
input = 'https://cran.r-project.org/doc/manuals/r-release/R-data.pdf'
text = tika(input) # magic happens
```

The `text` will be a UTF-8 character vector, in the same order as the `input`. Display a snippet using `cat`.

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

Get the words:

``` r
words = strsplit(tolower(text[1]), split='[^a-zA-Z]+')[[1]]
# remove pesky empty strings
words = words[words!='']
words[1:7] 
```

    [1] "r"       "data"    "import"  "export"  "version" "r"       "core"   

Get Metadata
------------

Metadata comes with the `json`,`xml` and `html` output options. A side effect is that Tika retains more document structure, such as table cells.

``` r
library('jsonlite')
json = tika(input,'J') # 'J' is a shortcut for 'jsonRecursive'
metadata = fromJSON(json[1])
```

See the structure of the metadata, or meta-metadata 🤯 .

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
     $ X-TIKA:parse_time_millis                   : chr "1301"
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
     $ resourceName                               : chr "rtika_file706d33c40772"
     $ tika:file_ext                              : chr ""
     $ tika_batch_fs:relative_path                : chr "tmp/RtmpOUGkGw/rtika_file706d33c40772"
     $ trapped                                    : chr "False"
     $ xmp:CreatorTool                            : chr "TeX"
     $ xmpTPg:NPages                              : chr "37"

Similar Packages
----------------

There is some overlap with many other text parsers, such as the R interface to antiword (See: <https://github.com/ropensci/antiword>). Listing all of them would take a huge amount of space, since Apache Tika processes over a thousand file types (See: <https://tika.apache.org/>). The main difference is that instead of specializing on a single format, Tika integrates dozens of specialist libraries from the Apache Foundation. Tika's unified approach offers a bit less control, and in return eases the parsing of digital archives filled with possibly unpredictable file types.

In September 2017, github.com user *kyusque* released `tikaR`, which uses the `rJava` package to interact with Tika (See: <https://github.com/kyusque/tikaR>). As of writing, it provided similar text and metadata extraction, but only `xml` output.

Back in March 2012, I started a similar project to interface with Apache Tika. My code also used low-level functions from the `rJava` package. I halted development after discovering that the Tika command line interface (CLI) was easier to use. My empty repository is at <https://r-forge.r-project.org/projects/r-tika/>.

I chose to finally develop this package after getting excited by Tika's new 'batch processor' module, written in Java. I'found the batch processor has very good efficiency when processing tens of thousands of documents. Further, it is not too slow for a single document either, and handles errors gracefully. Connecting `R` to the Tika batch processor turned out to be relatively simple, because the `R` code is simple. It uses the CLI to point Tika to the files. Simplicity, along with continuous testing, should ease integration. I anticipate that some researchers will need plain text output, while others will want `json` output. Some will want multiple processing threads to speed things up. These features are now implemented in `rtika`, although apparently not in `tikaR` yet.
