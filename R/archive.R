#' Archive a PODAAC stars object to a database
#' 
#' @export
#' @param x stars object
#' @param orig_filename chr the downloaded PODAAC filename (ends with .nc)
#' @param path char, the data path to write the data
#' @return tabular database as a tibble
archive_podaac = function(x, orig_filename,
                              path = "."){
  
  # for each time, variable, depth order in filename
  d = dim(x)
  if (length(d) == 3){
    if (d[3] > 1) {
      stop("please archive just one PODAAC file at a time")
    } else {
      x = dplyr::slice(x, "time", 1)
    }
  }
  db = decompose_podaac_filename(orig_filename) |>
    dplyr::filter(.data$var == names(x))
  ff = compose_filename(db, path)
  names(ff) <- db$var
  for (nm in names(ff)){
    f = ff[[nm]]
    ok = make_path(dirname(f))
    dummy = stars::write_stars(x[nm], f)
  }
  
  db
  
}