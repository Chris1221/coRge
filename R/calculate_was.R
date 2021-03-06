#' Takes gen file and calculates weighted allele scores (WAS)
#'
#' @param gen Truncated gen file with only causal snps
#' @param snps Truncated summary file with only causal snps
#' @param h2 Heritability estimate
#'
#' @importFrom dplyr %>%
#'
#' @return A vector of weighted allele scores
#' @export

calculate_was <- function(gen = NULL, snps = NULL, h2 = NULL){

  if(is.null(gen)) stop("Please input a gen matrix")
  if(is.null(snps)) stop("Please input a snps matrix")

  gen[, -(1:5)] %>%
    t -> genM

  # 9 betas
  b <- phen(.snps = snps, .combR = genM, .h2 = h2)

  for(i in seq(1, nrow(genM), by = 3)){

    genM[i,] <- 0*genM[i,]
    genM[i+1,] <- 1*genM[i+1,]
    genM[i+2,] <- 2*genM[i+2,]

  }
  
  maf <- snps$all_maf
  
  p <- (genM %*% b)

 
  p2 <- vector()

  for(i in seq(1, length(p), by = 3)){

    j <- (i+2)/3
    p2[j] <- p[i]+p[i+1]+p[i+2] - 2*sum(b*maf) # this might not be perfect

  }

  return(p2)

}
