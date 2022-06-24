#' extract generic
#'
#' @export
#' @param x \code{sf} object
#' @param y \code{ncdf4} object
#' @param ... Arguments passed to or from other methods
#' @return data frame of covariates (point, or raster)
extract <- function(x, y, ...) {
  UseMethod("extract")
}

extract.default <- function(x, y = NULL, ...){
  g <- sf::st_geometry(x)
  extract(g, y = y, ...)
}

extract.sfc_POINT <- function(x, y = NULL, ...){
  
}