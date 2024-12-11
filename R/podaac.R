# A function to apply single non-fancy (or fancy) quotes
#
# @param x character string
# @param fancy logical, curly quotes? (TRUE) or plain quotes (FALSE)?
# @return single quoted value of x
squote = function(x, fancy = FALSE){
  on.exit({
    options("useFancyQuotes")
  })
  orig_fancy = options("useFancyQuotes")
  options(useFancyQuotes = fancy)
  sQuote(x)
}

# A function to apply double non-fancy (or fancy) quotes
#
# @param x character string
# @param fancy logical, curly quotes? (TRUE) or plain quotes (FALSE)?
# @return double quoted value of x
dquote = function(x, fancy = FALSE){
  on.exit({
    options("useFancyQuotes")
  })
  orig_fancy = options("useFancyQuotes")
  options(useFancyQuotes = fancy)
  dQuote(x)
}

#' Extract a date form a PODAAC filename
#' 
#' @export
#' @param filename chr, one or more PODAAC filenames
#' @return a date for each filename
podaac_date = function(filename){
  basename(filename) |>
    substring(1, 8) |>
    as.Date(format = "%Y%m%d")
}


#' Format a date-time string
#' @export
#' @param x a Date or POSIXt object
#' @param fmt chr, the desired output format
#' @return character formatted date stamp
format_date = function(x, fmt = "%Y-%m-%dT00:00:00Z"){
  if (inherits(x, 'Date')){
    x = format(x[1], fmt)
  } else if (inherits(x, "POSIXt")){
    x = format(x[1], "%Y-%m-%dT%H:%M:%SZ")
  } else {
    # guess
    x = format(as.Date(x), format = fmt)
  }
  x
}

#' Run the PODAAC downloader script
#' 
#' @seealso \href{https://github.com/podaac/data-subscriber/blob/main/Downloader.md}{PO.DAAC downloader notes}
#' @export
#' @param collection char, the name of the collection
#' @param path char, the output path
#' @param logfile char, the path to the log file
#' @param start_date date, POSIXt or char as YYYY-mm-dd
#' @param end_date date, POSIXt or char as YYYY-mm-dd
#' @param app char, the name of the subscriber application
#' @param extra chr append this string to the command
#'   issued on the command line.  And empty string skips.
#' @return 0/1 from the system
podaac_downloader = function(
    collection = "MUR-JPL-L4-GLOB-v4.1",
    path = ghrsst_path("tmp"),
    logfile = ghrsst_path("downloader-log"),
    start_date = Sys.Date() - 3,
    end_date = Sys.Date(),
    app = 'podaac-data-downloader',
    extra = "") {
  
  if (FALSE){
    collection = "MUR-JPL-L4-GLOB-v4.1"
    path = ghrsst_path("tmp")
    logfile = ghrsst_path("tmp", "downloader-log")
    start_date = Sys.Date() - 1
    end_date = Sys.Date()
    app = 'podaac-data-downloader'
    extra = ""
  }
  

  if (Sys.which(app)  == "") stop("app not found:", app)
  
  ok = make_path(path)
  
  cmd = sprintf("-c %s -d %s -sd %s -ed %s --verbose %s",
                collection[1],
                dquote(normalizePath(path[1], mustWork = FALSE)),
                format_date(start_date[1]),
                format_date(end_date[1], fmt = "%Y-%m-%dT23:59:59Z"),
                extra) |>
    trimws(which = "right")

  msg = sprintf("[%s] downloader: %s %s",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
                app, 
                cmd)
    
   cat(msg, "\n", file = logfile, append = file.exists(logfile))
    
   ok = system2(app, cmd,
                stdout = logfile,
                stderr = logfile)
   ok
}


#' Run the PODAAC subscriber script
#' 
#' @seealso \href{https://github.com/podaac/data-subscriber/blob/main/Subscriber.md}{PO.DAAC subscriber notes}
#' @export
#' @param collection char, the name of the collection
#' @param path char, the output path
#' @param logfile char, the path to the log file
#' @param start_date date or char as YYYY-mm-dd
#' @param end_date date or char as YYYY-mm-dd
#' @param app char, the name of the subscriber application
#' @param extra chr append this string to the command
#'   issued on the command line.  And empty string skips.
#' @return 0/1 from the system
podaac_subscriber = function(
    collection = "MUR-JPL-L4-GLOB-v4.1",
    path = ghrsst_path("tmp"),
    logfile = ghrsst_path("subscriber-log"),
    start_date = Sys.Date() - 3,
    end_date = Sys.Date(),
    app = 'podaac-data-subscriber',
    extra = "") {
  
  if (FALSE){
    collection = "MUR-JPL-L4-GLOB-v4.1"
    path = ghrsst_path("tmp")
    logfile = ghrsst_path("downloader-log")
    start_date = Sys.Date() - 1
    end_date = Sys.Date()
    app = 'podaac-data-subscriber'
    extra = ""
  }
  
  
  if (Sys.which(app)  == "") stop("app not found:", app)
  
  ok = make_path(path)
  
  cmd = sprintf("-c %s -d %s -sd %s -ed %s --verbose %s",
                collection[1],
                dquote(normalizePath(path[1], mustWork = FALSE)),
                format_date(start_date[1]),
                format_date(end_date[1], fmt = "%Y-%m-%dT23:59:59Z"),
                extra) |>
    trimws(which = "right")
 
  msg = sprintf("[%s] subscriber: %s",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
                app, 
                cmd)

  cat(msg, "\n", file = logfile, append = file.exists(logfile))
  
  ok = system2(app, cmd,
               stdout = logfile,
               stderr = logfile)

  ok
}

#' List files stored in the PODAAC temporary directory
#' 
#' @export
#' @param path char, the data path
#' @param pattern char one or more regex patterns for the file search
#' @return char file listing
podaac_list = function(path = ghrsst_path("tmp"),
                       pattern =  "^.*\\.nc$"){
  
  lapply(pattern, 
    function(pat){
      list.files(path, pattern = pat, full.names = TRUE)
    }) |>
    unlist() |>
    unname()
}

#' Delete files stored in the PODAAC temporary directory
#' 
#' @export
#' @param path char, the data path
#' @param logfile char the name of the log file
#' @param verbose logical, output messages if TRUE
#' @param pattern char one or more regex patterns for the file search
#' @return named logical vector, TRUE indicates the file was successfully deleted
purge_podaac = function(path = ghrsst_path("tmp"),
                        logfile = file.path(path, "purge-log"),
                        verbose = FALSE,
                        pattern =  "^.*\\.nc$" ){
  
  
  
  remove_file = function(f){
    if (verbose){
      msg = sprintf("[%s] removing %s",
                    format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
                    basename(f))
      cat(msg, "\n", file = logfile, append = TRUE)
    }
    unlink(f, force = TRUE) <= 0
  }
  
  ff <- podaac_list(path, pattern = pattern)
  if (length(ff) > 0){
    ok = sapply(ff, remove_file)
    names(ok) <- basename(ff)
  } else {
    ok = logical()
  }
  
  invisible(ok)
}

