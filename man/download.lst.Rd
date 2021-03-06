% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download.lst.R
\name{download.lst}
\alias{download.lst}
\title{download.lst}
\usage{
download.lst(tile, date, product = "")
}
\arguments{
\item{tile}{\emph{character} vector specifying the target MODIS tile (e.g. "h01v01")}

\item{date}{a vector of class \emph{Date} containing the target download dates.}

\item{product}{Product to download (MOD11A2 or MYD11A2).}
}
\value{
A \emph{character} vector and hdf files.
}
\description{
Interface to download and process Land Surface Temperature (LST) data.
}
