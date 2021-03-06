% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/profileSimIBD.R
\name{profileSimIBD}
\alias{profileSimIBD}
\title{Simulate markers on a given IBD pattern}
\usage{
profileSimIBD(x, ibdpattern, ids = NULL, markers = NULL, seed = NULL)
}
\arguments{
\item{x}{A \code{ped} object.}

\item{ibdpattern}{A \code{genomeSim()} object, typically created by \code{\link[=ibdsim]{ibdsim()}}.
(See Examples).}

\item{ids}{A vector of ID labels. If NULL, all members of \code{x} are included.}

\item{markers}{A vector with names or indices of markers attached to \code{x}.}

\item{seed}{An integer seed for the random number generator.}
}
\value{
An object similar to \code{x}. but with simulated genotypes.
}
\description{
This function simulates genotypes for a set of markers, conditional on a
specific underlying IBD pattern.
}
\details{
It should be noted that the only \emph{random} part of this function is the
selection of founder alleles for each marker. Given those, all other
genotypes in the pedigree are determined by the underlying IBD pattern.
}
\examples{
# A pedigree with two siblings
x = nuclearPed(2)

# Attach 3 linked markers on chromosome 1
pos = c(20, 50, 70)   # marker positions in megabases
mlist = lapply(pos, function(i)
  marker(x, alleles = letters[1:10], chrom = 1, posMb = i))
x = setMarkers(x, mlist)

# Simulate the underlying IBD pattern in the pedigree
s = ibdsim(x, 1, map = uniformMap(M = 1, chrom = 1), seed = 123)[[1]]

# Simulate genotypes for the sibs conditional on the given IBD pattern
profileSimIBD(x, s, ids = 3:4, seed = 123)

# With a different seed
profileSimIBD(x, s, ids = 3:4, seed = 124)

}
\seealso{
\code{\link[=ibdsim]{ibdsim()}}
}
