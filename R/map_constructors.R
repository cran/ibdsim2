#' Uniform recombination maps
#'
#' Create a uniform recombination map of a given length.
#'
#' @param Mb Map length in megabases.
#' @param cM Map length in centiMorgan.
#' @param M Map length in Morgan.
#' @param cmPerMb A positive number; the cM/Mb ratio.
#' @param chrom A chromosome label, which may be any string. The values "X" and
#'   "23" have a special meaning, both resulting in the `Xchrom` attribute being
#'   set to TRUE.
#'
#' @return An object of class `chromMap`. See [loadMap()] for details.
#'
#' @seealso [loadMap()], [customMap()]
#'
#' @examples
#' m = uniformMap(Mb = 1, cM = 2:3)
#' m
#' m$male
#' m$female
#' 
#' mx = uniformMap(M = 1, chrom = "X")
#' mx
#' mx$male
#' mx$female
#' 
#' @export
uniformMap = function(Mb = NULL, cM = NULL, M = NULL, cmPerMb = 1, 
                      chrom = 1) {
  
  if(is.null(cM) &&  is.null(M) && is.null(Mb))
    stop2("No map length indicated")
  
  if(!is.null(cM) && !is.null(M)) 
    stop2("Either `cM` or `M` must be NULL")
  
  if(!is.null(Mb) && !(is.numeric(Mb) && length(Mb) == 1))
    stop2("When non-NULL, `Mb` must be a numeric of length 1: ", Mb)
  
  if(!is.null(cM) && !(is.numeric(cM) && length(cM) < 3))
    stop2("When non-NULL, `cM` must be a numeric of length 1 or 2: ", cM)
  
  if(!is.null(M) && !(is.numeric(M) && length(M) < 3))
    stop2("When non-NULL, `M` must be a numeric of length 1 or 2: ", M)
  
  if (is.null(cM))
    cM = if (!is.null(M)) M * 100 else cmPerMb * Mb
  
  if (is.null(Mb)) 
    Mb = cM / cmPerMb
  
  if(toupper(chrom) %in% c("23", "X"))
    chrom = "X"
    
  if(chrom == "X") {
    if((length(Mb) > 1 && Mb[1] > 0) || (length(cM) > 1 && cM[1] > 0))
      stop2("Male X chromosome cannot have positive length")
  }
  
  # If length 0, return early
  if(Mb == 0) {
    female = cbind(Mb = 0, cM = 0)
    male = if(chrom == "X") NULL else female
    return(chromMap(male, female, chrom = chrom))
  }
  
  Mb = unname(rep(Mb, length.out = 2))
  cM = unname(rep(cM, length.out = 2))
  
  female = cbind(Mb = c(0, Mb[2]), cM = c(0, cM[2]))
  male = if(chrom == "X") NULL else 
    cbind(Mb = c(0, Mb[1]), cM = c(0, cM[1]))
  
  chromMap(male, female, chrom = chrom)
}


#' Load a built-in genetic map
#'
#' This function loads one of the built-in genetic maps. Currently, the only
#' option is a detailed human recombination map, based on the publication by
#' Halldorsson et al. (2019).
#'
#' For reasons of speed and efficiency, the map published by map Halldorsson et
#' al. (2019) has been thinned down to ~14,000 data points.
#'
#' NOTE: The built-in map was updated in version 2.3.0, adding more accurate
#' physical chromosome endpoints. While still based on Halldorsson et al.
#' (2019), the new version also uses a better thinning algorithm, allowing to
#' reduce the number of data points from ~38,000 to ~14,000 without losing
#' accuracy. The old version is available as a separate dataset
#' `legacy_decode19` for backwards reproducibility.
#'
#' By setting `uniform = TRUE`, a uniform version of the map is returned, in
#' which each chromosome has the same genetic lengths as in the original, but
#' with constant recombination rates. This gives much faster simulations and may
#' be preferable in some applications.
#'
#' @param map The name of the wanted map, possibly abbreviated. Default:
#'   "decode19".
#' @param chrom A vector containing a subset of the numbers 1,2,...,23,
#'   indicating which chromosomes to load. As a special case, `chrom = "X"` is
#'   synonymous to `chrom = 23`. Default: `1:22` (the autosomes).
#' @param uniform A logical. If FALSE (default), the complete inhomogeneous map
#'   is used. If TRUE, a uniform version of the same map is produced, i.e., with
#'   the correct physical range and genetic lengths, but with constant
#'   recombination rates along each chromosome.
#' @param sexAverage A logical, by default FALSE. If TRUE, a sex-averaged map is
#'   returned, with equal recombination rates for males and females.
#'
#' @return An object of class `genomeMap`, which is a list of `chromMap`
#'   objects. A `chromMap` is a list of two matrices, named "male" and "female",
#'   with various attributes:
#'
#'   * `physStart`: The first physical position (Mb) on the chromosome covered
#'   by the map
#'
#'   * `physEnd`: The last physical position (Mb) on the chromosome covered by
#'   the map
#'
#'   * `physRange`: The physical map length (Mb), equal to `physEnd - physStart`
#'
#'   * `mapLen`: A vector of length 2, containing the centiMorgan lengths of the
#'   male and female strands
#'
#'   * `chrom`: A chromosome label
#'
#'   * `Xchrom`: A logical. This is checked by `ibdsim()` and other function, to
#'   select mode of inheritance

#'
#' @seealso [uniformMap()], [customMap()]
#'
#' @references Halldorsson et al. _Characterizing mutagenic effects of
#'   recombination through a sequence-level genetic map._ Science (2019).
#'
#' @examples
#' # By default, the complete map of all 22 autosomes is returned
#' loadMap()
#'
#' # Uniform version
#' m = loadMap(uniform = TRUE)
#' m
#' 
#' # Check chromosome 1
#' m1 = m[[1]]
#' m1
#' m1$male
#' m1$female
#'
#' # The X chromosome
#' loadMap(chrom = "X")[[1]]
#' 
#' @export
loadMap = function(map = "decode19", chrom = 1:22, uniform = FALSE, sexAverage = FALSE) {
  
  if(!is.character(map) || length(map) != 1)
    stop2("Argument `map` must be a character of length 1")
  
  if(!all(chrom %in% c(1:23, "X")))
    stop2("Unknown chromosome name: ", setdiff(chrom, c(1:23, "X")))
  
  if(is.character(chrom)) {
     chrom[chrom == "X"] = 23
     chrom = as.numeric(chrom)
  }
  
  if(dup <- anyDuplicated.default(chrom))
    stop2("Duplicated chromosome: ", chrom[dup])
  
  if(!is.logical(uniform) || length(uniform) != 1 || is.na(uniform))
    stop2("Argument `uniform` must be either TRUE or FALSE")
  
  if(!is.logical(sexAverage) || length(sexAverage) != 1 || is.na(sexAverage))
    stop2("Argument `sexAverage` must be either TRUE or FALSE")
  
  if(sexAverage && isTRUE(any(c(23, "X") %in% chrom)))
    stop2("X-chromosomal map cannot be sex averaged")
  
  
  # For now only 'decode19' is implemented
  builtinMaps = c("decode19", "legacy_decode19")
  mapno = pmatch(map, builtinMaps)
  if(is.na(mapno))
    stop2("Unknown map: ", map)
  
  map = builtinMaps[mapno]
  genome = get(map)[chrom]
  
  if(!uniform && !sexAverage)
    return(genome)
  
  if(uniform) {
    chroms = lapply(genome, function(chr) {
      chrom = attr(chr, "chrom")
      mb    = attr(chr, "physRange")
      cm    = attr(chr, "mapLen")
      
      if(sexAverage) 
        cm = mean(cm)
      
      uniformMap(Mb = mb, cM = cm, chrom = chrom)
    })
    
    return(genomeMap(chroms))
  }
  
  if(sexAverage) {
    genome[] = lapply(genome, function(chr) {
      if(!identical(chr$male$Mb, chr$female$Mb))
        stop2("Sex averaging requires equal map positions in males and females")
      
      # Average each data point
      chr$male$cM = chr$female$cM = (chr$male$cM + chr$female$cM)/2
      
      # Chromosome map length attribute
      meanLen = mean(attr(chr, "mapLen"))
      attr(chr, "mapLen") = c(male = meanLen, female = meanLen)
      
      chr
    })
    
    return(genome)
  }
}


#' Custom recombination map
#'
#' Create custom recombination maps for use in [ibdsim()].
#'
#' The column names of `x` must include either
#'
#' * `chrom`, `mb` and `cm`   (sex-averaged map)
#'
#' or
#'
#' * `chrom`, `mb`, `male` and `female`  (sex-specific map)
#'
#' Upper-case letters are allowed in these names. The `mb` column should contain
#' physical positions in megabases, while `cm`, `male`, `female` give the
#' corresponding genetic position in centiMorgans.
#'
#' @param x A data frame or matrix. See details for format specifications.
#'
#' @return An object of class `genomeMap`.
#'
#' @seealso [uniformMap()], [loadMap()]
#'
#' @examples
#' # A map including two chromosomes.
#' df1 = data.frame(chrom = c(1, 1, 2, 2),
#'                  mb = c(0, 2, 0, 5),
#'                  cm = c(0, 3, 0, 6))
#' map1 = customMap(df1)
#' map1
#'
#' # Use columns "male" and "female" to make sex specific maps
#' df2 = data.frame(chrom = c(1, 1, 2, 2),
#'                  mb = c(0, 2, 0, 5),
#'                  male = c(0, 3, 0, 6),
#'                  female = c(0, 4, 0, 7))
#' map2 = customMap(df2)
#' map2
#'
#' @export
customMap = function(x) {
  if(is.matrix(x))
    x = as.data.frame(x)
  
  if(!is.data.frame(x))
    stop2("Argument `x` must be a data frame or matrix. Received: ", class(x))
  
  nms = names(x)
  nmsSmall = tolower(nms)
  if(!"chrom" %in% nmsSmall) stop2('`x` must have a column named "chrom". See `?customMap`')
  if(!"mb" %in% nmsSmall) stop2('`x` must have a column named "mb". See `?customMap`')
  sexEq = "cm" %in% nmsSmall
  sexSpec = "male" %in% nmsSmall && "female" %in% nmsSmall
  if(!(sexEq || sexSpec))
    stop2('`x` must either have a colum named "cm", or two columns named "male" and "female". See `?customMap`')
  
  names(x) = nmsSmall
  
  # Split by chromosome
  chrList = split(x, x$chrom)
  
  chroms = lapply(chrList, function(chr) {
    if(sexEq) {
      male = female = chr[c("mb", "cm")]
    }
    else {
      male = chr[c("mb", "male")]
      female = chr[c("mb", "female")]
    }
    chromMap(male, female, chrom = chr$chrom[1])
  })
  
  genomeMap(chroms)
}


###########################
### Internal constructors
###########################

chromMap = function(male, female = male, chrom = 1) {
  
  Xchrom = chrom == "X"
  if(Xchrom) {
    if(!is.null(male))
      stop2("Male map on X must be NULL")

    dmf = dim(female)
    if(is.null(dmf) || dmf[2] != 2)
      stop2("Female map does not have two columns")
    
    # Convert matrix/tibbles/etc
    female = as.data.frame(female)
    names(female) = c("Mb", "cM")
    
    physF = female$Mb
    if(physF[dmf[1]] > 1e9) {
      female$Mb = female$Mb / 1e6
    }
  }
  else {
    dmm = dim(male)
    dmf = dim(female)
    if(is.null(dmm) || dmm[2] != 2)
      stop2("Male map does not have two columns")
    if(is.null(dmf) || dmf[2] != 2)
      stop2("Female map does not have two columns")
    
    # Convert matrix/tibbles/etc
    male = as.data.frame(male)
    female = as.data.frame(female)
    
    # Fix names
    names(male) = names(female) = c("Mb", "cM")
    
    physM = male$Mb
    physF = female$Mb
    
    if(physM[1] != physF[1])
      stop2("First position must be the same in male and female maps: ", c(physM[1], physF[1]))
    
    if(physM[dmm[1]] != physF[dmf[1]])
      stop2("End position must be the same in male and female maps: ", c(physM[dmm[1]], physF[dmf[1]]))
  
    if(physF[dmf[1]] > 1e9) {
      male$Mb = male$Mb / 1e6
      female$Mb = female$Mb / 1e6
    }
  }
  
  
  physStart = physF[1]
  physEnd = physF[dmf[1]]
  physRange = physEnd - physStart
  mapLen = c(male = if(Xchrom) 0 else male$cM[dmm[1]], female = female$cM[dmf[1]])
  
  structure(list(male = male, female = female), physStart = physStart, physEnd = physEnd, 
            physRange = physRange, mapLen = mapLen, chrom = chrom, Xchrom = Xchrom, class = "chromMap")
}

isXmap = function(x) {
  attr(x, "Xchrom")
}

genomeMap = function(x) {
  if(isGenomeMap(x))
    return(x)
  
  if(isChromMap(x))
    x = list(x)
  
  if(!all(sapply(x, isChromMap)))
    stop2("Cannot convert to genomeMap")
  
  structure(x, class = "genomeMap")
}
