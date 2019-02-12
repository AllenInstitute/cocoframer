#' Read AIBS .nrrd files
#'
#' This function reads the .nrrd format used by
#' AIBS, containing 32-bit integer values with 15 header lines.
#'
#' @param file The .nrrd file to read
#' @param dims The dimensions of the array. Default is for 25 nm CCF arrays: c(528,320,456)
#' @param header_lines The number of header lines in the .nrrd file. Default is 15.
#'
#' @return a 3 dimensional integer array with dims
#'
# @export Note: As of 2018-12-24, this function fails to retrieve correct values, so not exported.
read_aibs_nrrd <- function (file,
                            dims = c(528, 320, 456),
                            header_lines = 15)
{
  con <- file(file, "rb")

  # skip header lines
  h <- readLines(con, n = header_lines)

  # data is gzipped
  fc <- gzcon(con)
  d <- readBin(con,
               what = "integer",
               n = prod(dims),
               size = 4,
               endian = "little")

  close(con)

  array(d, dim = dims)

}
