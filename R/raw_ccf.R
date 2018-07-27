#' Download the CCF Annotation object and return a 3D Array of values
#'
#' No parameters
#'
#' @return a 3-dimensional array with 25 micron resolution. Dimension are:
#' \itemize{
#'   \item x, 528: anterior/posterior
#'   \item y, 320: superior/inferior
#'   \item z, 456: left/right
#' }
get_ccf_annotation <- function() {
  # CCF Annotation Dimensions
  vol_dims <- c(528, 320, 456)
  # Download and read the CCF Annotation coordinates
  temp <- tempfile()
  download.file("http://download.alleninstitute.org/informatics-archive/current-release/mouse_annotation/P56_Mouse_annotation.zip", temp)

  raw_file <- unz(temp, "annotation.raw", "rb")
  vol_raw <- readBin(raw_file, "integer", size = 4, n = vol_dims[1]*vol_dims[2]*vol_dims[3])
  close(raw_file)

  file.remove(temp)

  array(vol_raw, dim = vol_dims)
}
