ghrsst
================

> This is version “v0.2”, which switches from use of OPeNDAP to PODAAC’s
> convenience apps. In addition to opening NetCDF connections, version
> “v0.1” (now defunct) demonstrated how you could extract point or small
> polygons form the NetCDF. This new package is only about fetching and
> reading data from PODAAC, not about extracting points or polygons from
> the data. To learn more about extraction, see the
> [sf](https://r-spatial.github.io/sf/) and
> [stars](https://r-spatial.github.io/stars/) tutorials.

Access [GHRSST](https://www.ghrsst.org/) (aka
[MUR](https://www.earthdata.nasa.gov/about/competitive-programs/measures/multi-sensor-ultra-high-resolution-sst-field))
data and manage data from R. [PODAAC](https://podaac.jpl.nasa.gov/)
provides two nice command line tools (`podaac-data-downloader` and
`podaac-data-subscriber`). Our focus here is on
`podaac-data-downloader`.

Currently `podaac-data-downloader` only [downloads the global
file](https://github.com/podaac/data-subscriber/issues/134#issuecomment-1546155900),
but there are plans afoot to add a `--subset` argument so only portions
of the global raster are transferred. Until then we download the entire
globe, but then provide tools for subsetting.

We made a [short
video](https://drive.google.com/file/d/1GuX5eufkTtb3XU4gLN6_YS3h4Dc3pttW/view?usp=share_link)
explaining this packages (while still under development), it’s a decent
but informal walk through.

# Requirements

## Application from [PODAAC](https://podaac.jpl.nasa.gov/)

Install
[`data-subscriber`](https://podaac.github.io/tutorials/quarto_text/DataSubscriberDownloader.html)
from PODAAC. Be sure to set your credentials.

**Note** we have had good luck installing
[pipx](https://pypi.org/project/pipx/) rather than
[pip](https://pypi.org/project/pip/) as `pipx` will handle installation
into environments.

## Packages from CRAN

- [R v4.1+](https://www.r-project.org/)
- [rlang](https://CRAN.R-project.org/package=rlang)
- [dplyr](https://CRAN.R-project.org/package=httr)
- [sf](https://CRAN.R-project.org/package=sf)
- [stars](https://CRAN.R-project.org/package=stars)
- [tidync](https://CRAN.R-project.org/package=tidync)

## Installation

    remotes::install_github("BigelowLab/ghrsst", ref = "data-subscriber")

# Usage

``` r
suppressPackageStartupMessages({
  library(rnaturalearth)
  library(dplyr)
  library(sf)
  library(ghrsst)
  library(stars)
})
```

## Set up default paths

Data files are downloaded to a default data path; you can override this
as needed. It’s convenient to set it once and then forget it. Below is
an example, but you should adjust the path to suit your own needs.

    path = "/Users/ben/Library/CloudStorage/Dropbox/data/ghrsst"
    ghrsst::make_path(path)
    ghrsst::set_root_path(path)

## Downloading

Downloading is mostly about selecting the start and end dates. Accepting
the defaults, files will be downloaded to `ghrsst::ghrsst_path("tmp")`
directory, which is not quite the same as a temporary directory. You’ll
want to clean out old files on a regular basis and we provide a tool to
help with that (see below).

``` r
ok = ghrsst::podaac_downloader(start_date = as.Date("2020-02-01"), end_date = "2020-02-03")
print(ok)
```

    ## [1] 0

## Listing the downloaded files

``` r
ff = ghrsst::podaac_list() |>
  print()
```

    ## [1] "/Users/ben/Library/CloudStorage/Dropbox/data/ghrsst/tmp/20200201090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc"
    ## [2] "/Users/ben/Library/CloudStorage/Dropbox/data/ghrsst/tmp/20200202090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc"
    ## [3] "/Users/ben/Library/CloudStorage/Dropbox/data/ghrsst/tmp/20200203090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc"
    ## [4] "/Users/ben/Library/CloudStorage/Dropbox/data/ghrsst/tmp/20200204090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc"

## Reading the downloaded data

At this point you don’t really need this package as you could read the
downloaded file(s) with your favorite NetCDF reader:
[ncdf4](https://CRAN.R-project.org/package=ncdf4),
[RNetCDF](https://CRAN.R-project.org/package=RNetCDF),
[stars](https://CRAN.R-project.org/package=stars),
[terra](https://CRAN.R-project.org/package=terra), or
[tidync](https://CRAN.R-project.org/package=tidync); any will do nicely.
We provide a wrapper around
[tidync](https://CRAN.R-project.org/package=tidync) to read into `stars`
objects.

``` r
namibia = get_namibia()
s = read_podaac(ff, bb = namibia, var = c("analysed_sst", "sst_anomaly"))
s
```

    ## stars object with 3 dimensions and 2 attributes
    ## attribute(s), summary of first 1e+05 cells:
    ##                  Min. 1st Qu.  Median        Mean 3rd Qu.    Max. NA's
    ## analysed_sst  289.851 293.653 294.663 294.2342406 295.038 296.241 2913
    ## sst_anomaly    -2.020  -0.515  -0.278  -0.2617328   0.009   0.974 2913
    ## dimension(s):
    ##      from   to     offset  delta refsys point x/y
    ## x       1 1701          0   0.01 WGS 84 FALSE [x]
    ## y       1 1301        -29   0.01 WGS 84 FALSE [y]
    ## time    1    4 2020-02-01 1 days   Date    NA

``` r
coast = rnaturalearth::ne_coastline(scale = "medium", returnclass = "sf") |>
  sf::st_geometry() |>
  sf::st_crop(namibia)
extra_plot = function(...){
  plot(coast, col = "orange", lwd = 2, add = TRUE)
}
plot(s['analysed_sst'], hook = extra_plot)
```

![](README_files/figure-gfm/plot1-1.png)<!-- -->

``` r
plot(s['sst_anomaly'], hook = extra_plot)
```

![](README_files/figure-gfm/plot2-1.png)<!-- -->

## Archiving your data

There are many reasons to want to keep your subset of data. We provide
minimalist tools to doing so, and allowing you to read back data to suit
your needs.

### Archive one file at a time

We archive into a designated directory so that we can recover the files
later. Since they are subsets they are relatively light to restore at
some later date. We build a metadata database, in the form or a data
frame, that helps us keep track of what we have downloaded and archived.

``` r
path = ghrsst::ghrsst_path("namibia")
newdb = lapply(ff,
  function(filename){
    ghrsst::read_podaac(filename, bb = namibia, 
                            var = c("analysed_sst", "sst_anomaly")) |>
      ghrsst::archive_podaac(filename, path = path)
  }) |>
  dplyr::bind_rows() |>
  dplyr::glimpse()
```

    ## Rows: 8
    ## Columns: 12
    ## $ date         <date> 2020-02-01, 2020-02-01, 2020-02-02, 2020-02-02, 2020-02-…
    ## $ year         <dbl> 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020
    ## $ month        <dbl> 2, 2, 2, 2, 2, 2, 2, 2
    ## $ time         <chr> "090000", "090000", "090000", "090000", "090000", "090000…
    ## $ rdac         <chr> "JPL", "JPL", "JPL", "JPL", "JPL", "JPL", "JPL", "JPL"
    ## $ level        <chr> "L4_GHRSST", "L4_GHRSST", "L4_GHRSST", "L4_GHRSST", "L4_G…
    ## $ type         <chr> "SSTfnd", "SSTfnd", "SSTfnd", "SSTfnd", "SSTfnd", "SSTfnd…
    ## $ product      <chr> "MUR", "MUR", "MUR", "MUR", "MUR", "MUR", "MUR", "MUR"
    ## $ reg          <chr> "GLOB", "GLOB", "GLOB", "GLOB", "GLOB", "GLOB", "GLOB", "…
    ## $ gds_version  <chr> "v02.0", "v02.0", "v02.0", "v02.0", "v02.0", "v02.0", "v0…
    ## $ file_version <chr> "fv04.1", "fv04.1", "fv04.1", "fv04.1", "fv04.1", "fv04.1…
    ## $ var          <chr> "analysed_sst", "sst_anomaly", "analysed_sst", "sst_anoma…

The database is a very simple decomposition of the original file name,
plus the added variable name. Each selected variable from each file has
been written to the path as a TIFF file.

#### Save the database

We write the database to a file. Note that this makes sense for a brand
new database, but if you are adding to an existing database you’ll want
to checkout `append_database()`. But for this tutorial we can simply
write the new file.

``` r
newdb = ghrsst::write_database(newdb, path)
```

#### Read the database back

Now we can read the database back (pretend you paused for lunch).

``` r
path = ghrsst::ghrsst_path("namibia")
db = read_database(path) |>
  print()
```

    ## # A tibble: 8 × 12
    ##   date        year month time   rdac  level     type   product reg   gds_version
    ##   <date>     <dbl> <dbl> <chr>  <chr> <chr>     <chr>  <chr>   <chr> <chr>      
    ## 1 2020-02-01  2020     2 090000 JPL   L4_GHRSST SSTfnd MUR     GLOB  v02.0      
    ## 2 2020-02-01  2020     2 090000 JPL   L4_GHRSST SSTfnd MUR     GLOB  v02.0      
    ## 3 2020-02-02  2020     2 090000 JPL   L4_GHRSST SSTfnd MUR     GLOB  v02.0      
    ## 4 2020-02-02  2020     2 090000 JPL   L4_GHRSST SSTfnd MUR     GLOB  v02.0      
    ## 5 2020-02-03  2020     2 090000 JPL   L4_GHRSST SSTfnd MUR     GLOB  v02.0      
    ## 6 2020-02-03  2020     2 090000 JPL   L4_GHRSST SSTfnd MUR     GLOB  v02.0      
    ## 7 2020-02-04  2020     2 090000 JPL   L4_GHRSST SSTfnd MUR     GLOB  v02.0      
    ## 8 2020-02-04  2020     2 090000 JPL   L4_GHRSST SSTfnd MUR     GLOB  v02.0      
    ## # ℹ 2 more variables: file_version <chr>, var <chr>

#### Reading in rasters

Now filter the files for just the one(s) you want, let’s say Feb 1 and 2
for sst_anomaly.

``` r
x = db |>
  dplyr::filter(date <= as.Date("2020-02-02"), var == "sst_anomaly") |>
  ghrsst::read_ghrsst(path = path)
x
```

    ## stars object with 3 dimensions and 1 attribute
    ## attribute(s), summary of first 1e+05 cells:
    ##               Min. 1st Qu. Median       Mean 3rd Qu.  Max. NA's
    ## sst_anomaly  -2.02  -0.515 -0.278 -0.2617328   0.009 0.974 2913
    ## dimension(s):
    ##      from   to     offset  delta refsys point x/y
    ## x       1 1701          0   0.01 WGS 84 FALSE [x]
    ## y       1 1301        -29   0.01 WGS 84 FALSE [y]
    ## time    1    2 2020-02-01 1 days   Date    NA

``` r
plot(x, hook = extra_plot)
```

    ## downsample set to 3

![](README_files/figure-gfm/plot_ghrsst-1.png)<!-- -->

You can also request multiple variables.

``` r
x = db |>
  dplyr::filter(date <= as.Date("2020-02-02"), 
                var %in% c("sst_anomaly", "analysed_sst")) |>
  ghrsst::read_ghrsst(path = path)
x
```

    ## stars object with 3 dimensions and 2 attributes
    ## attribute(s), summary of first 1e+05 cells:
    ##                  Min. 1st Qu.  Median        Mean 3rd Qu.    Max. NA's
    ## analysed_sst  289.851 293.653 294.663 294.2342406 295.038 296.241 2913
    ## sst_anomaly    -2.020  -0.515  -0.278  -0.2617328   0.009   0.974 2913
    ## dimension(s):
    ##      from   to     offset  delta refsys point x/y
    ## x       1 1701          0   0.01 WGS 84 FALSE [x]
    ## y       1 1301        -29   0.01 WGS 84 FALSE [y]
    ## time    1    2 2020-02-01 1 days   Date    NA

## Cleaning up

Without intentional cleanup, the \*download\*\* directory may grow to an
unreasonable size. We provide a function to purge that directory as
needed. Not that this does not delete files from any archive you may
have developed.

    purge_podaac()
