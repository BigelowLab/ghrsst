#' Compose a filename from a archive database
#'
#' @export
#' @param x database (tibble), with date, var, depth
#' @param path character, the root path for the filename
#' @param ext character, the filename extension to apply (please include the dot)
#' @return character vector of filenames in form
#'         \code{<path>/YYYY/mm/datetime-rdac-level-type-product-region-gds_version-file_version_var.ext}
compose_filename <- function(x, path = ".", ext = ".tif"){
  
  # <path>/YYYY/mmdd/id__datetime_depth_period_variable_treatment.ext
  file.path(path,
            format(x$date, "%Y/%m"),
            sprintf("%s%s-%s-%s-%s-%s-%s-%s-%s-%s%s",
                    format(x$date, "%Y%m%d"), 
                    x$time,
                    x$rdac,
                    x$level,
                    x$type,
                    x$product,
                    x$reg,
                    x$gds_version,
                    x$file_version,
                    x$var,
                    ext))
}

#' Decompose an archived filename (.tif) into a database.
#' 
#' Not to be confused with \link{decompose_podaac_filename}
#'
#' @export
#' @param x character, vector of one or more filenames
#' @param ext character, the extension to remove (including dot)
#' @return table (tibble) database
decompose_filename = function(x = c("20200201090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1-analyzed_sst.tif",
                                   "20070503120000-UKMO-L4_GHRSST-SSTfnd-OSTIA-GLOB-v02.1-fv01.0-mask.tif"),
                              ext = ".tif"){
  
  # a tidy version of gsub
  global_sub <- function(x, pattern = ".tif", replacement = "", fixed = TRUE, ...){
    gsub(pattern, replacement, x, fixed = fixed, ...)
  }
  
  
  x = basename(x) |>
    global_sub(pattern = ext)
  
  ss = strsplit(x, "-", fixed = TRUE)
  
  dplyr::tibble(
    date = podaac_date(x),
    time = substring(x, 9, 14),
    rdac = sapply(ss, '[[',2),
    level = sapply(ss, '[[',3),
    type = sapply(ss, '[[',4),
    product = sapply(ss, '[[',5),
    reg = sapply(ss, '[[',6),
    gds_version = sapply(ss, '[[',7),
    file_version = sapply(ss, '[[',8),
    var = sapply(ss, '[[',9))  |>
  dplyr::mutate(year = as.numeric(format(.data$date, "%Y")),
                month = as.numeric(format(.data$date, "%m")),
                .after = 1)
}


#' Decompose a PODAAC original filename into a database of variables.
#' 
#' Here we follow [this](https://isi-sbx.ifremer.fr/jeff/gds/naming.html) nice
#' documentation of the naming convetion.
#' 
#' @export
#' @param x chr one or more filenames
#' @param vars chr or stars object,  The names of the variables in the file. If a stars object we'll
#'   take the variable names from that.
#' @return a database tibble
decompose_podaac_filename = function(x = c("20200201090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc",
                                           "20070503120000-UKMO-L4_GHRSST-SSTfnd-OSTIA-GLOB-v02.1-fv01.0.nc"),
                                     vars = c("analysed_sst", "analysis_error", "mask", 
                                              "sea_ice_fraction", "dt_1km_data", "sst_anomaly")){
  
  if (inherits(vars, "stars")) vars = names(vars)
  # a tidy version of gsub
  global_sub <- function(x, pattern= ".nc", replacement = "", fixed = TRUE, ...){
    gsub(pattern, replacement, x, fixed = fixed, ...)
  }
  
  x = basename(x) |>
    global_sub()
  
  ss = strsplit(x, "-", fixed = TRUE)
  
  var = dplyr::tibble(var = vars)
  db = dplyr::tibble(
    date = podaac_date(x),
    time = substring(x, 9, 14),
    rdac = sapply(ss, '[[',2),
    level = sapply(ss, '[[',3),
    type = sapply(ss, '[[',4),
    product = sapply(ss, '[[',5),
    reg = sapply(ss, '[[',6),
    gds_version = sapply(ss, '[[',7),
    file_version = sapply(ss, '[[',8))
  dplyr::cross_join(db, var) |>
    dplyr::mutate(year = as.numeric(format(.data$date, "%Y")),
                  month = as.numeric(format(.data$date, "%m")),
                  .after = 1)
}

#' Construct a database tibble give a data path
#'
#' @export
#' @param path character the directory to catalog
#' @param pattern character, the filename pattern (as glob) to search for
#' @param ... other arguments for \code{\link{decompose_filename}}
#' @return tibble database
build_database <- function(path, pattern = "*.tif", ...){
  if (missing(path)) stop("path is required")
  list.files(path[1], pattern = utils::glob2rx(pattern),
             recursive = TRUE, full.names = TRUE) |>
    decompose_filename(...)
}


#' Read a file-list database
#'
#' @export
#' @param path character the directory with the database
#' @param filename character, optional filename
#' @return a tibble
read_database <- function(path,
                          filename = "database.csv.gz"){
  if (missing(path)) stop("path is required")
  filepath <- file.path(path[1], filename[1])
  stopifnot(file.exists(filepath))
  # date var depth
  readr::read_csv(filepath, 
                  col_types = readr::cols(
                    date = readr::col_date(format = "%Y-%m-%d"),
                    year = readr::col_double(),
                    month = readr::col_double(),
                    time = readr::col_character(),
                    rdac = readr::col_character(),
                    level = readr::col_character(),
                    type = readr::col_character(),
                    product = readr::col_character(),
                    reg = readr::col_character(),
                    gds_version = readr::col_character(),
                    file_version = readr::col_character(),
                    var = readr::col_character()
                  ))
}

#' Write the file-list database
#'
#' We save only date (YYYY-mm-dd), param, trt (treatment) and src (source). If you
#' have added other variables to the database they will be dropped in the saved
#' file.
#'
#' @export
#' @param x the tibble or data.frame database
#' @param path character the directory to where the database should reside
#' @param filename character, optional filename
#' @return the input tibble
write_database <- function(x, path,
                           filename = "database.csv.gz"){
  if (missing(path)) stop("path is required")
  filepath <- file.path(path[1], filename[1])
  dummy <- x |>
    readr::write_csv(filepath)
  invisible(x)
}

#' Append one or more rows to a database.
#'
#' The databases must have identical column classes and names.
#'
#' @export
#' @param db tibble, the database to append to
#' @param x tibble, the new data to append.  If this has no rows then the
#'  original database is returned
#' @param rm_dups logical, if TRUE remove duplicates from combined databases.
#'  If x has no rows then this is ignored.
#' @return the updated database tibble
append_database <- function(db, x, rm_dups = TRUE){
  
  if (!identical(colnames(db), colnames(x)))
    stop("x column names must be identical to db column names\n")
  
  if (!identical(sapply(db, class), sapply(x, class)))
    stop("x column classes must be identical to db column classes\n")
  
  if (nrow(x) > 0){
    db <- dplyr::bind_rows(db, x)
    if (rm_dups) db <- dplyr::distinct(db)
  }
  
  db
}