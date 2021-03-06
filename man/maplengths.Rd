% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map_utils.R
\name{maplengths}
\alias{maplengths}
\alias{mapLen}
\alias{mapLen.chromMap}
\alias{mapLen.genomeMap}
\alias{physRange}
\alias{physRange.chromMap}
\alias{physRange.genomeMap}
\title{Physical and genetic map lengths}
\usage{
mapLen(x, ...)

\method{mapLen}{chromMap}(x, sex = c("male", "female"), ...)

\method{mapLen}{genomeMap}(x, sex = c("male", "female"), ...)

physRange(x, ...)

\method{physRange}{chromMap}(x, ...)

\method{physRange}{genomeMap}(x, ...)
}
\arguments{
\item{x}{A \code{chromMap} or \code{genomeMap} object.}

\item{...}{Not used.}

\item{sex}{Either "male", "female" or both.}
}
\value{
\code{mapLen()} returns a numeric of the same length as \code{sex}, with the
genetic length(s) in centiMorgan.

\code{physRange()} returns the physical length (in Mb) of the chromosome/genome
covered by the map. For example, for a chromosome map starting at 2 Mb and
ending at 8 Mb, the output is 6.
}
\description{
Utility functions for extracting the physical or genetic length of chromosome
maps and genome maps.
}
\examples{
m = loadMap(chrom = 1:2)
m

# Applied to `genomeMap` object:
physRange(m)
mapLen(m)

# Applied to `chromMap` object:
physRange(m[[1]])
mapLen(m[[1]])

}
\seealso{
\code{\link[=loadMap]{loadMap()}}, \code{\link[=uniformMap]{uniformMap()}}
}
