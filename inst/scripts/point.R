suppressPackageStartupMessages({
  library(dplyr)
  library(sf)
  library(ghrsst)
  library(xyzt)
})


x <- xyzt::read_gom() |>
  xyzt::as_POINT()
X <- ncdf4::nc_open(mur_url())
(y <- ghrsst::extract(x,X, varname = "analysed_sst", verbose = TRUE))
(z <- dplyr::bind_cols(x, y))


ncdf4::nc_close(X)
