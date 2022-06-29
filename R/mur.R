#' Craft a MUR URL for a given date
#' 
#' @export
#' @param date character, POSIXt or Date the date to retrieve
#' @param where character ignored (for now)
#' @param root character, the root URL
#' @param product character, provides version and extend info, leave as default
#' @return one or more URLs
mur_url <- function(date = Sys.Date() - 2,
                    where = "opendap",
                    root = file.path("https://opendap.jpl.nasa.gov",
                    "opendap/OceanTemperature/ghrsst/data/GDS2/L4", 
                    "GLOB/JPL/MUR/v4.1"),
                    product = "JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc"){

      #"2017/001/20170101090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc" 
  if (inherits(date, "character")) date <- as.Date(date)                    
  name <- sprintf("%s/%s/%s090000-%s",
                  format(date, "%Y"), 
                  format(date, "%j"), 
                  format(date, "%Y%m%d"),
                  product)
  file.path(root, name)                     
}