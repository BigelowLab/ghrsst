% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/podaac.R
\name{podaac_downloader}
\alias{podaac_downloader}
\title{Run the PODAAC downloader script}
\usage{
podaac_downloader(
  collection = "MUR-JPL-L4-GLOB-v4.1",
  path = ghrsst_path("tmp"),
  logfile = ghrsst_path("downloader-log"),
  start_date = Sys.Date() - 3,
  end_date = Sys.Date(),
  app = "podaac-data-downloader",
  extra = ""
)
}
\arguments{
\item{collection}{char, the name of the collection}

\item{path}{char, the output path}

\item{logfile}{char, the path to the log file}

\item{start_date}{date, POSIXt or char as YYYY-mm-dd}

\item{end_date}{date, POSIXt or char as YYYY-mm-dd}

\item{app}{char, the name of the subscriber application}

\item{extra}{chr append this string to the command
issued on the command line.  And empty string skips.}
}
\value{
0/1 from the system
}
\description{
Run the PODAAC downloader script
}
\seealso{
\href{https://github.com/podaac/data-subscriber/blob/main/Downloader.md}{PO.DAAC downloader notes}
}
