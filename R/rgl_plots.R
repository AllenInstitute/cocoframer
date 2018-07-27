#' Plot a 3D CCF structure specified by its structure ID as points
#'
#' @param ccf_arr a CCF annotation array
#' @param structure_id The ID number of the desired CCF structure
#'
#' @return An rgl points3d plot
plot_ccf_structure_points <- function(ccf_arr,
                                      structure_id) {
  library(reshape2)
  library(rgl)

  vol_melt <- melt(ccf_arr)
  vol_melt <- vol_melt[vol_melt$value > 0,]

  if(!structure_id %in% unique(vol_melt$value)) {
    stop("Structure not found in ccf_arr.")
  }

  str_melt <- vol_melt[vol_melt$value == structure_id,]

  points3d(str_melt$Var1,str_melt$Var2,str_melt$Var3)

}
