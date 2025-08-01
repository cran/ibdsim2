stop2 = function(...) {
  a = lapply(list(...), toString)
  a = append(a, list(call. = FALSE))
  do.call(stop, a)
}

# Test that input is a positive (or similar) integer.
isCount = function(x, minimum = 1) {
  isTRUE(length(x) == 1 &&
           (is.integer(x) || (is.numeric(x) && x == as.integer(x))) &&
           x >= minimum)
}



.getAlleles = function(chromdata, posvec) {
  posvec[posvec < 0] = 0
  rbind(pos2allele(chromdata[[1]], posvec),
    pos2allele(chromdata[[2]], posvec))
}


pos2allele = function(haplo, posvec) { 
  # haplo = matrix with 2 columns (breaks - allele)
  if(is.null(haplo))
    return(rep(0, length(posvec)))
  indices = findInterval(posvec, haplo[, 1])
  haplo[indices, 2]
}

# Call Rcpp version of sample.int(, ... replace = TRUE)
.sampleInt = function(n, size) {
  if(n == 2 && size == 1)
    sample_12_C()
  else
    sample_int_C(n, size)
}

.sortDouble = function(x) {
  len = length(x)
  if(len == 1) 
    return(x)
  if(len == 2) {
    if(x[1] > x[2]) 
      return(x[2:1])
    else 
      return(x)
  }
  if(len == 3) {
    a = x[1]; b = x[2]; c = x[3]
    if (b < a) {
      tmp = a
      a = b
      b = tmp
    }
    if (c < b) {
      tmp = b
      b = c
      c = tmp
    }
    if (b < a) {
      tmp = a
      a = b
      b = tmp
    }
    return(c(a,b,c))
  }
  if(!is.numeric(x))
    stop2("Sorting method expected a numerical vector")
  sort_dbl_C(x) # [order(x, method = "shell")]
}


# Fast version of t(combn(n,2))
.comb2 = function(n) {
  switch(max(min(n,5),1),
    `dim<-`(integer(0), c(0L, 2L)),
    `dim<-`(c(1L, 2L), c(1L, 2L)),
    `dim<-`(c(1L, 1L, 2L, 2L, 3L, 3L), c(3L, 2L)),
    `dim<-`(c(1L, 1L, 1L, 2L, 2L, 3L, 2L, 3L, 4L, 3L, 4L, 4L), c(6L, 2L)),
    {
      v1 = rep.int(seq_len(n - 1), (n - 1):1)
      v2 = sequence.default((n - 1):1, 2:n)
      cbind(v1, v2, deparse.level = 0)
    })
}

`%||%` = function(x, y) {
  if (is.null(x)) y
  else x
}

# Safe versions of mean/min/max
safeMean = function(v, default = 0) if(length(v)) mean(v) else default
safeMin = function(v, default = 0) if(length(v)) min(v) else default
safeMax = function(v, default = 0) if(length(v)) max(v) else default

# Private version of `toString`
#  * Converts sequences to ranges: 1,2,3,5,6,7 -> "1-3, 5-7"
#  * Default returns if NULL or empty
toString2 = function(x, ifempty = "-", ifnull = ifempty) {
  if(is.null(x))
    return(ifnull)
  if(!length(x))
    return(ifempty)
  
  xInt = suppressWarnings(as.integer(x))
  
  # If not all integers, return toString(x)
  if(any(is.na(xInt) | x != xInt))
    return(toString(x))

  conseqs = unname(split(xInt, cumsum(c(0, diff(xInt) != 1))))
  
  if(all(lengths(conseqs) == 1))
    return(toString(x))
  
  rngs = sapply(conseqs, function(v) {
    if(length(v) == 1) as.character(v)
    else if(length(v) == 2) toString(v)
    else sprintf("%d-%d", min(v), max(v))
  })
  paste(rngs, collapse = ", ")
}

