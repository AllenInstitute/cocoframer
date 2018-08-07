#' Find ABA RNA ISH experiment IDs for a specific gene symbol
#'
#' @param gene_symbol The gene symbol to search for
#'
#' @return a character object with all of the gene symbols matching your query
#'
get_gene_aba_ish_ids <- function(gene_symbol) {
  library(xml2)

  api_query <- paste0("http://api.brain-map.org/api/v2/data/query.xml?criteria=model::SectionDataSet,rma::criteria,[failed$eq'false'],products[abbreviation$eq'Mouse'],plane_of_section[name$eq'coronal'],genes[acronym$eq'",gene_symbol,"']")

  api_xml <- read_xml(api_query)

  api_ids <- xml_find_all(api_xml,"//id")

  xml_text(api_ids)
}

#' Retrieve gridded ABA RNA ISH results for a specific API id
#'
#' @param api_id The ID of the SectionDataSet to retrieve
#' @param values Which values to retrieve. Options are "energy", "density", "intensity", and "injection". Default = "energy".
#'
#' @return a 3d array with values for each position in the ABA mouse gridAnnotation space at 200 um resolution. Dimension are:
#' \itemize{
#'   \item x, 67: anterior/posterior
#'   \item y, 41: superior/inferior
#'   \item z, 58: left/right
#' }
get_aba_ish_data <- function(api_id,
                             values = "energy") {
  #ABA API query
  api_query <- paste0("http://api.brain-map.org/grid_data/download/",api_id,"?include=",values)

  # CCF Annotation Dimensions
  vol_dims <- c(67, 41, 58)
  # Download and read the CCF Annotation coordinates
  temp <- tempfile(fileext = ".zip")
  download.file(api_query, temp, mode = "wb")

  raw_file <- unz(temp, "energy.raw", "rb")
  vol_raw <- readBin(raw_file, "double", size = 4, n = vol_dims[1]*vol_dims[2]*vol_dims[3])
  close(raw_file)

  file.remove(temp)

  array(vol_raw, dim = vol_dims)
}

