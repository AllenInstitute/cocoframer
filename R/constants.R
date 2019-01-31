#' Dimensions for AIBS CCF data at different resolutions
#'
#' Data at 1um: CCF Meshes
#' Data at 25um: Annotation grids and most gridded TissueCyte datasets
#' Data at 200um: Gridded ISH datasets and related annotations
#'
#' @param res The resolution of the dataset. Can be "1um","25um", or "200um". Default is "25um".
#'
#' @return a 3-element integer vector with the x,y,z dimensions.
#'
#' x is anterior<->posterior
#' y is ventral<->dorsal
#' z is left<->right
#'
aibs_dims <- function(res = "25um") {
  if(res == "1um") {
    c(13200, 8000, 11400)
  } else if(res == "25um") {
    c(528, 320, 456)
  } else if(res == "200um") {
    c(67, 41, 58)
  }
}
