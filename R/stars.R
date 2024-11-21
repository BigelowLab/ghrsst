#' Read GHRSST data as stars
#' 
#' @export 
#' @param db tibble database
#' @param path chr the data path
#' @return a stars object
read_ghrsst = function(db, path){
  if(missing(path)) stop("path must be provided")
  
  ss = dplyr::group_by(db, .data$var) |>
    dplyr::group_map(
      function(tbl, key){
        ff = compose_filename(tbl, path = path)
        x = stars::read_stars(ff, along = list(time = tbl$date)) |>
          rlang::set_names(tbl$var[1])
      }, .keep = TRUE)
    
  do.call(c, append(ss, list(along =  NA_integer_)))
}

#' Read one or more PODAAC files as stars objects.  
#'  
#' You can extract the entore globe, but these are large files and you may be
#' happier to select a subset using the `bb` argument. If multiple filenames are
#' passed then 
#' 
#' @export
#' @param filename chr one or more filenames
#' @param bb bbox or object from which a bbox can be extracted
#' @param var char, one or more variables to return. By default 'analysed_sst', but
#'   there is also 'analysis_error', 'mask', 'sea_ice_fraction', 'dt_1km_data', and
#'   'sst_anomaly'
#' @return stars object with one or variables and one or more bands
read_podaac = function(filename, 
                       bb = get_namibia(),
                       var = 'analysed_sst'){
  
  filename = sort(filename)
  dates = podaac_date(filename)
  bb = sf::st_bbox(bb)
  xx = lapply(filename,
    function(f){
      x = tidync::tidync(f) |>
        tidync::hyper_filter(lon = .data$lon >= bb[['xmin']] & .data$lon <= bb[['xmax']],
                             lat = .data$lat >= bb[['ymin']] & .data$lat <= bb[['ymax']],
                             time = .data$index == 1) |>
        tidync_as_stars(var = var)
      x
    })
  do.call(c, append(xx, list(along = list(time = dates))))

}


#' Cast a tidync object to stars
#'
#' Taken from https://github.com/ropensci/tidync/issues/68#issuecomment-484773118
#' @export
#' @param x tidync object
#' @param var char, one or more variables to return. By default 'analysed_sst', but
#'   there is also 'analysis_error', 'mask', 'sea_ice_fraction', 'dt_1km_data', and
#'   'sst_anomaly'
#' @return stars object
tidync_as_stars <- function(x, var = 'analysed_sst') {
  
  stopifnot(inherits(x, "tidync"))
  
  a = tidync::hyper_array(x, select_var = var, drop = TRUE)
  
  ax = attr(a, "transforms")
  
  lon = ax$lon |>
    dplyr::filter(.data$selected == TRUE) |>
    dplyr::pull(1) 
  dx <- lon[2]-lon[1]
  xr = range(lon)
  
  lat = ax$lat |>
    dplyr::filter(.data$selected == TRUE) |>
    dplyr::pull(1) 
  dy = lat[2]-lat[1]
  yr = range(lat)
  
    
  bbox = sf::st_bbox(c(xmin = xr[1], xmax = xr[2], ymin = yr[1], ymax = yr[2]),
                     crs = 4326)
  
  ss = lapply(names(a),
              function(nm){
                m = a[[nm]]
                dimnames(m) <- NULL
                s = stars::st_as_stars(m) |>
                  sf::st_set_crs(4326) |>
                  rlang::set_names(nm) |>
                  stars::st_set_dimensions(names = c("x", "y"))
                d = stars::st_dimensions(s)
                d$x$offset = lon[1]
                d$x$delta = dx
                d$y$offset = lat[1]
                d$y$delta = dy
                stars::st_dimensions(s) <- d
                s
              })
  do.call(c, append(ss, list(along =  NA_integer_)))
}
