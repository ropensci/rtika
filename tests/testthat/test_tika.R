context("Connecting to Tika")

# urls <- c("https://cran.r-project.org/doc/manuals/r-release/R-data.pdf"
#          , "https://cran.r-project.org/doc/manuals/r-release/R-exts.epub"
#          , "https://cran.r-project.org/doc/manuals/r-release/R-FAQ.html")
#input <- replicate(length(urls), tempfile('rtika_tests'))
# input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
# for (i in seq_along(urls)) {
#   download.file(urls[i], input[i])
# }

test_that("gets valid path", {
    path <- tika_jar()
    expect_true(length(path)==1)
    expect_true(class(path)=='character')
    expect_true(file.exists(path))
})

test_that("check_md5_sum only works with character strings ", {
    expect_error(tika_check(777))
})

test_that("check_md5_sum fails with wrong checksum", {
    expect_false(tika_check('not a checksum'))
})


test_that("md5_sum is correct for this version", {
    expect_true(tika_check('e2720c2392c1bd6634cc4a8801f7363a'))
})


# causes problem with travis, but not locally. May need to skip
test_that("tika warns with url to nowhere without curl package", {
  nowhere <- 'http://www.predict-r.com/rtika_testing_coverage_file_not_here.txt'
  expect_warning(tika(nowhere,lib.loc='') )
})
# causes problem with travis, but not locally. May need to skip
test_that("tika stops when output_dir is root", {
  input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
  expect_error( tika(input[1] , output_dir = file.path('/') ) )
})

test_that("tika parses a local pdf without curl packages", {
  input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
  text <- tika(input[1], lib.loc = "")
  expect_equal(length(text), 1)
  expect_true(!is.na(text[1]))
  expect_true(nchar(text[1]) > 0)
})

test_that("tika handles fake file without curl packages", {
  nowhere <- file.path("/rtika_fake_file_not_here.txt")
  expect_warning(text <- tika(nowhere, lib.loc = "") )
  expect_equal(length(text), 1)
  expect_equal(text[1], as.character(NA))
})

test_that("tika parses a single remote pdf without curl package", {
  urls <- c("https://cran.r-project.org/doc/manuals/r-release/R-data.pdf"
            , "https://cran.r-project.org/doc/manuals/r-release/R-exts.epub"
            , "https://cran.r-project.org/doc/manuals/r-release/R-FAQ.html")
  text <- tika(urls[1], lib.loc = "")
  expect_equal(length(text), 1)
  expect_true(!is.na(text[1]))
  expect_true(nchar(text[1]) > 0)
})


# causes problem with travis, but not locally. Skipping on github for now.
test_that("tika warns with url to nowhere with curl package", {
  nowhere <- 'http://www.predict-r.com/rtika_testing_coverage_file_not_here.txt'
  expect_warning(tika(nowhere) )
})

test_that("tika parses single local pdf", {
  input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
  text <- tika(input[1])
  expect_equal(length(text), 1)
  expect_true(!is.na(text[1]))
  expect_true(nchar(text[1]) > 0)
})

test_that("tika parses multiple local files", {
  input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
  text <- tika(input)
  expect_equal(length(text), length(input))
  expect_true(!any(is.na(text)))
  expect_true(all(nchar(text) > 0))
})


test_that("tika parses a single remote pdf", {
  urls <- c("https://cran.r-project.org/doc/manuals/r-release/R-data.pdf"
            , "https://cran.r-project.org/doc/manuals/r-release/R-exts.epub"
            , "https://cran.r-project.org/doc/manuals/r-release/R-FAQ.html")
  text <- tika(urls[1])
  expect_equal(length(text), 1)
  expect_true(!is.na(text[1]))
  expect_true(nchar(text[1]) > 0)
})


test_that("tika warns with path to nowhere", {
  expect_warning(tika(file.path("/rtika_fake_file_not_here.txt")))
})

test_that("tika outputs NA with a path to nowhere", {
  nowhere <- file.path("/rtika_fake_file_not_here.txt")
  text <- ''
  text <- expect_warning(tika(nowhere))
  expect_equal(length(text), 1)
  expect_equal(text[1], as.character(NA))
})

test_that("tika outputs NA with a path to nowhere in right order", {
  nowhere <- file.path("/rtika_fake_file_not_here.txt")
  input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
  text <- tika(c(input[1], nowhere, input[2]))
  expect_equal(text[2], as.character(NA))
  expect_equal(length(text), 3)
  expect_true(all(nchar(text[c(1, 3)]) > 0))
})

test_that("tika warns with NA input", {
  nowhere <- as.character(NA)
  expect_warning( text <- tika(nowhere))
  expect_equal(length(text), 1)
  expect_equal(text[1], as.character(NA))
})





test_that("tika outputs parsable xml", {
 # library('xml2')
  input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
  text <- tika_xml(input)
  processed_xml <- NA
  processed_xml <- xml2::read_xml(text[1])
  expect_true(!is.na(processed_xml))
  
  processed_xml <- NA
  processed_xml <- xml2::read_xml(text[2])
  expect_true(!is.na(processed_xml))
  
  processed_xml <- NA
  processed_xml <- xml2::read_xml(text[3])
  expect_true(!is.na(processed_xml))
})

test_that("tika outputs parsable html", {
 # library('xml2')
  input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
  text <- tika_html(input)
  processed_html <- NA
  processed_html <- xml2::read_html(text[1])
  expect_true(!is.na(processed_html))
  
  processed_html <- NA
  processed_html <- xml2::read_html(text[2])
  expect_true(!is.na(processed_html))
  
  processed_html <- NA
  processed_html <- xml2::read_html(text[3])
  expect_true(!is.na(processed_html))
})


test_that("tika outputs parsable json", {
 # library('jsonlite')
  input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
  text <- tika_json(input)
  processed_json <- data.frame()
  processed_json <- jsonlite::fromJSON(text[1])
  expect_true(nrow(processed_json)==1)
  
  processed_json <- data.frame()
  processed_json <- jsonlite::fromJSON(text[2])
  expect_true(nrow(processed_json)==1)
  
  processed_json <- data.frame()
  processed_json <- jsonlite::fromJSON(text[3])
  expect_true(nrow(processed_json)==1)
  
})

test_that("tika_text works", {
  input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
  text <- tika_text(input[1])
  expect_equal(length(text), 1)
  expect_true(!is.na(text[1]))
  expect_true(nchar(text[1]) > 0)
})

test_that("tika puts files into the specified output_dir", {
  input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
  test_dir <- tempfile("testthat_rtika_test")
  dir.create(test_dir)
  test_dir <- normalizePath(test_dir, winslash = "/")
  text <- tika(input[1], output_dir = test_dir, cleanup=TRUE)
  files <- list.files(test_dir
                      , include.dirs = FALSE
                      , recursive = TRUE)
  expect_true(length(files) > 0)
  full_path <- file.path(test_dir, files)
  
  expect_true(all(file.exists(full_path)))
  file_info <- file.info(full_path)
  expect_true(!all(file_info$isdir))
})


test_that("tika cleans up", {
  input <- c("R-data.pdf","R-exts.epub","R-FAQ.html")
  text <- tika(input[1], cleanup = TRUE)
  expect_equal(length(file.path(tempdir()
                 , list.files(tempdir()
                , pattern = "^rtika_file"))), 0)
  expect_equal(length(file.path(tempdir()
                , list.files(tempdir()
                , pattern = "^rtika_dir"))), 0)
})







