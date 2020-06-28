#' ibdsim2: Simulation of chromosomal regions shared by family members
#'
#' Simulation of segments shared identical-by-descent (IBD) by pedigree members.
#' Using sex specific recombination rates along the human genome (Kong et al.,
#' 2010), phased chromosomes are simulated for all pedigree members. Additional
#' features include calculation of realised IBD coefficients and IBD segment
#' distribution plots.
#'
#' @docType package
#' @import pedtools
#' @importFrom stats rpois runif
#'
#' @references Kong et al. *Fine-scale recombination rate differences between
#'   sexes, populations and individuals.* Nature 467, 1099--1103 (2010).
#'   \doi{https://doi.org/10.1038/nature09525}
#'
#' @name ibdsim2
NULL

## usethis namespace: start
#' @importFrom Rcpp sourceCpp evalCpp
#' @useDynLib ibdsim2, .registration = TRUE
#' @importFrom Rcpp sourceCpp
## usethis namespace: end
NULL