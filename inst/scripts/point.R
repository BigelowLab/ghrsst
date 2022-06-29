suppressPackageStartupMessages({
  library(dplyr)
  library(sf)
  library(ghrsst)
  library(xyzt)
})


x <- xyzt::read_gom() |>
  xyzt::as_POINT()
X <- ncdf4::nc_open(mur_url())

y <- dplyr::bind_cols(x, ghrsst::extract(x,X))


ncdf4::nc_close(X)
