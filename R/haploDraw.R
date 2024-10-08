#' Draw haplotypes onto a pedigree plot
#'
#' Visualise the IBD pattern of a single chromosome, by drawing haplotypes onto
#' the pedigree.
#'
#' @param x A `ped` object.
#' @param ibd A `genomeSim` object, typically made by [ibdsim()].
#' @param chrom A chromosome number, needed if `ibd` contains data from multiple
#'   chromosomes.
#' @param ids A vector indicating for which pedigree members haplotypes should
#'   be drawn. If NULL (default), all individuals in `ibd` are included.
#' @param unit Either "mb" (default) or "cm".
#' @param L A positive number: the chromosome length. By default derived from
#'   `ibd`.
#' @param pos A vector recycled to `pedsize(x)`, indicating where haplotypes
#'   should be drawn relative to the pedigree symbols: 0 = no haplotypes; 1 =
#'   below; 2 = left; 3 = above; 4 = right. By default, all are placed below.
#' @param cols A colour vector corresponding to the alleles in `ibd`.
#' @param height The height of the haplotype rectangles in units of the pedigree
#'   symbol height. Default: 4.
#' @param width The width of the haplotype rectangles in units of the pedigree
#'   symbol width. Default: 0.75.
#' @param sep The separation between haplotypes within a pair, measured in
#'   pedigree symbol widths.
#' @param dist The distance between pedigree symbols and the closest haplotype,
#'   measured in pedigree symbol widths.
#' @param keep.par A logical, by default FALSE; passed on to `plot.ped()`.
#' @param ... Further arguments passed on to `plot.ped()`, e.g. `margins` and
#'   `cex`. See `?plotmethods` for a complete list.
#'
#' @return None.
#'
#' @examples
#'
#' ###############################
#' # Example 1: A family quartet #
#' ###############################
#'
#' x = nuclearPed(2)
#' map = uniformMap(M = 1)
#' s = ibdsim(x, map = map, seed = 4276)
#'
#' haploDraw(x, s)
#'
#' # Custom colours and placements
#' haploDraw(x, s, cols = c(3,7,2,4), pos = c(2,4,2,4))
#'
#' # Standard plot options apply
#' haploDraw(x, s, margins = 3, cex = 1.5, title = "Full sibs")
#'  
#' 
#' ###########################
#' # Example 2: Autozygosity #
#' ###########################
#'
#' x = halfCousinPed(0, child = TRUE)
#' map = uniformMap(M = 1)
#' s = ibdsim(x, map = map, skipRecomb = c(1,3), seed = 2)
#'
#' # Only include relevant individuals (skip 1 and 3)
#' haploDraw(x, s, ids = c(2,4,5,6), pos = c(1,2,4,4))
#'
#' ###############################
#' # Example 3: X-chromosomal sims
#' ###############################
#'
#' x = nuclearPed(2, sex = 2:1)
#' s = ibdsim(x, N = 1, map = uniformMap(M = 1, chrom = "X"), seed = 123)
#'
#' haploDraw(x, s)
#'
#'
#' @importFrom graphics par plot rect
#' @export
haploDraw = function(x, ibd, chrom = NULL, ids = NULL, unit = "mb", L = NULL, 
                     pos = 1, cols = NULL, height = 4, width = 0.75, sep = 0.75, 
                     dist = 1, keep.par = FALSE, ...) {
  
  #if(!is.ped(x))
  #  stop2("Argument `x` must be a `ped` object")
  
  # Unless explicit `keep.par = TRUE`, ensure par is reset
  if(!keep.par) {
    op = par(no.readonly = TRUE)
    on.exit(par(op), add = TRUE)
  }
  
  labs = labels(x)
  idsIBD = extractIds(ibd)
  N = sum(pedsize(x))
  
  if(is.null(ids))
    ids = idsIBD
  else {
    ids = as.character(ids)
    if(!all(ids %in% idsIBD))
      stop2("ID not found in `ibd` matrix: ", setdiff(ids, idsIBD))
  }
  
  if(length(pos) == 1) {
    pos = rep(pos, length(ids))
    names(pos) = ids
  }
  if(length(pos) != length(ids))
    stop2("Arguments `pos` and `ids` are incompatible")
  
  if(is.null(names(pos)))
    names(pos) = ids
  if(!all(ids %in% names(pos)))
    stop2("ID not found in `pos` vector: ", setdiff(ids, names(pos)))
  
  # Extend `pos` to all individuals
  allpos = rep(0L, N)
  names(allpos) = labs
  allpos[ids] = pos[ids]
  
  # If `ibd` is list of 1 sim: simplify
  if(inherits(ibd, "genomeSimList") && length(ibd) == 1)
    ibd = ibd[[1]]

  Xchrom = isXsim(ibd)
  isXmale = Xchrom & (labs %in% males(x))
  
  # If `chrom` is given, check compatibility and select rows from `ibd`
  chrvec = ibd[, 'chrom']
  multipleChrom = length(unique.default(chrvec)) > 1
  if(multipleChrom && is.null(chrom))
    stop2("`ibd` contains data from multiple chromosomes. Use `chrom` to select one.")
  if(length(chrom) > 1)
    stop2("More than one chromosome selected: ", chrom)
  
  if(!is.null(chrom)) { # by now chrom has length 1
    if(chrom == 23 || chrom == "X") {
      if(!Xchrom)
        stop2("`chrom = 'X'` is indicated, but the given simulation is not X-chromosomal")
      chrom = 23
    }
    if(!chrom %in% chrvec)
      stop2("Chromosome not present in the simulation: ", chrom)
    ibd = ibd[chrvec == chrom, , drop = FALSE]
  }
  
  if(is.null(cols)) {
    DEFCOLS = list(
      red    = c("#FFC1C1", "#B20000"), 
      blue   = c("#C1D4FF", "#0033B2"), 
      orange = c("#FFD4A5", "#FF6600"), #"#FFDAC1",
      green  = c("#C1FFC1", "#006600"),
      yellow = c("#FFFFC1", "#FFD700"), 
      purple = c("#E0C1FF", "#800080"), 
      teal   = c("#C1FFFF", "#008080"),
      pink   = c("#FFC1E0", "#FF1493"), 
      brown  = c("#D5C1B9", "#8B4513"), 
      gray   = c("#D1D1D1", "#4B4B4B"))
    
    cols = unlist(DEFCOLS[seq_along(founders(x))], use.names = FALSE)
    #cols = seq_len(2*length(founders(x)))
  }
  
    
  # Names of start/end columns
  startCol = switch(unit, mb = "startMB", cm = "startCM")
  endCol = switch(unit, mb = "endMB", cm = "endCM")
  
  # Chromosome length
  if(is.null(L))
    L = sum(ibd[, endCol] - ibd[, startCol])
  
  # Get pedigree layout and scaling
  alignment  = .pedAlignment(x, ...)
  annotation = .pedAnnotation(x, ...)
  scaling    = .pedScaling(alignment, annotation)
  
  # Symbol coordinates
  xpos = alignment$x
  ypos = alignment$y
  
  # Height/width of ped symbols
  symh = scaling$boxh
  symw = scaling$boxw

  H = height * symh
  W = width  * symw
  SEP = sep * symw
  DIST = dist * symw
  
  # Center of haplo-pair
  X = Y = rep(NA, N)
  for(i in seq_len(N)) {
    if(allpos[i] == 0) 
      next
    switch(allpos[i], { # 1
      X[i] = xpos[i]
      Y[i] = ypos[i] + symh + DIST + H/2
    }, { #2
      X[i] = xpos[i] - symw/2 - DIST - W - SEP/2
      Y[i] = ypos[i] + symh/2
    }, { #3
      X[i] = xpos[i]
      Y[i] = ypos[i] - DIST - H/2
    }, { #4
      X[i] = xpos[i] + symw/2 + DIST + W + SEP/2
      Y[i] = ypos[i] + symh/2
    })
  }
  
  # Possibly extend plot limits (user coords)
  usr = scaling$usr
  xlim = c(min(usr[1:2], X - SEP/2 - W, na.rm = TRUE),
           max(usr[1:2], X + SEP/2 + W, na.rm = TRUE))
  ylim = c(min(usr[3:4], Y - H/2, na.rm = TRUE),
           max(usr[3:4], Y + H/2, na.rm = TRUE))

  # Draw the pedigree
  p = pedtools::drawPed(alignment, annotation, xlim = xlim, ylim = ylim, keep.par = TRUE, ...)
  
  # Draw rectangles!
  for(i in seq_len(N)) {  
    if(is.na(X[i]))
      next

    id = labs[i]
    if(isXmale[i]) { # draw maternal haplotype only
      matCol = paste0(id, ":m")
      segsMat = mergeSegments(ibd, by = matCol)
      addRect(X[i], Y[i], width = W, height = H, 
              sta = segsMat[, startCol]/L, col = cols[segsMat[, matCol]])
    }
    else {
      # Paternal haplotype
      patCol = paste0(id, ":p")
      segsPat = mergeSegments(ibd, by = patCol)
      addRect(X[i] - SEP/2 - W/2, Y[i], width = W, height = H, 
              sta = segsPat[, startCol]/L, col = cols[segsPat[, patCol]])
  
      # Maternal haplotype
      matCol = paste0(id, ":m")
      segsMat = mergeSegments(ibd, by = matCol)
      addRect(X[i] + SEP/2 + W/2, Y[i], width = W, height = H, 
              sta = segsMat[, startCol]/L, col = cols[segsMat[, matCol]])
    }
  }
  
  invisible(p)
}


# Function for drawing a single haplotype
addRect = function(xmid, ymid, width, height, sta = 0, col = seq_along(sta)+1) {
  stopifnot(length(col) == length(sta))
  
  bottom = ymid - height/2
  sto = c(sta[-1], 1)
  for(i in seq_along(sta))
    rect(xleft = xmid - width/2, ybottom = bottom + height*sta[i],
         xright = xmid + width/2, ytop = bottom + height*sto[i], 
         col = col[i])
}
