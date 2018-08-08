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

#' Retrieve gridded ABA RNA ISH results for a specific SectionDataSet
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
  api_query <- paste0("http://api.brain-map.org/grid_data/download/",
                      api_id,"?include=",values)

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

#' Get per-structure ABA RNA ISH results for a specific SectionDataSet
#'
#' @param api_id The ID of the SectionDataSet to retrieve
#' @param keep_non_atlas Logical, whether to keep or filter structures without an atlas id value. Default = FALSE.
#'
#' @return a data.frame with per-structure atlas expression values:
#' \itemize{
#' \item name: full name of the atlas structure
#' \item acronym: structure acronym
#' \item atlas_id: atlas id value for structure
#' \item density: normalized expression density value
#' \item energy: normalized expression as intensity/density
#' \item sum_expressing_pixel_intensity
#' \item sum_expressing_pixels
#' \item sum_pixel_intensity
#' \item sum_pixels
#' \item voxel_energy_mean
#' \item voxel_energy_cv
#' }
get_aba_ish_structure_data <- function(api_id,
                                       keep_non_atlas = FALSE) {
  library(xml2)

  # ABA API query
  api_query <- paste0("http://api.brain-map.org/api/v2/data/SectionDataSet/query.xml?id=",
                      api_id,"&include=structure_unionizes%28structure%29")

  # ABA API XML
  api_xml <- read_xml(api_query)

  # Parsing the XML for specific results
  results <- data.frame(name = xml_text(xml_find_all(api_xml,"//safe-name")),
                        acronym = xml_text(xml_find_all(api_xml,"//acronym")),
                        atlas_id = xml_text(xml_find_all(api_xml,"//atlas-id")),
                        density = xml_double(xml_find_all(api_xml,"//expression-density")),
                        energy = xml_double(xml_find_all(api_xml,"//expression-energy")),
                        sum_expressing_pixel_intensity = xml_double(xml_find_all(api_xml,"//sum-expressing-pixel-intensity")),
                        sum_expressing_pixels = xml_double(xml_find_all(api_xml,"//sum-expressing-pixels")),
                        sum_pixel_intensity = xml_double(xml_find_all(api_xml,"//sum-pixel-intensity")),
                        sum_pixels = xml_double(xml_find_all(api_xml,"//sum-expressing-pixels")),
                        voxel_energy_mean = xml_double(xml_find_all(api_xml,"//voxel-energy-mean")),
                        voxel_energy_cv = xml_double(xml_find_all(api_xml,"//voxel-energy-cv")))

  if(!keep_non_atlas) {
    results <- results[results$atlas_id != "",]
  }

  return(results)
}

#' Query the ABA API to get relationships between ISH experiments and genes
#'
#' No parameters
#'
#' @return a data.frame with two columns: id and gene_symbol
#'
get_exp_gene_relationships <- function() {
  library(xml2)
  library(purrr)

  api_query <- "http://api.brain-map.org/api/v2/data/query.xml?criteria=model::SectionDataSet,rma::criteria,[failed$eq'false'],products[abbreviation$eq'Mouse'],plane_of_section[name$eq'coronal']&include=genes"

  api_xml <- read_xml(api_query)

  total_rows <- as.numeric(xml_attr(api_xml,"total_rows"))

  api_list <- as_list(api_xml)

  api_genes <- map_chr(1:50,
                       function(x) {
                         if(length(api_list[[1]][[1]][[x]][["genes"]]) > 0) {
                           api_list[[1]][[1]][[x]][["genes"]][["gene"]][["acronym"]][[1]]
                         } else {
                           ""
                         }
                       })

  results <- data.frame(id = xml_text(xml_find_all(api_xml,"//section-data-set/id")),
                        gene_symbol = api_genes)

  n_batches <- floor(total_rows/50)

  for(i in 2:n_batches) {
    print(i)
    start_row <- (i - 1) * 50
    if(i == n_batches) {
      num_rows <- total_rows - start_row
    } else {
      num_rows <- 50
    }
    batch_api_query <- paste0(api_query,"&start_row=",start_row,"&num_rows=",num_rows)
    api_xml <- read_xml(batch_api_query)
    api_list <- as_list(api_xml)

    api_genes <- map_chr(1:num_rows,
                         function(x) {
                           if(length(api_list[[1]][[1]][[x]][["genes"]]) > 0) {
                             api_list[[1]][[1]][[x]][["genes"]][["gene"]][["acronym"]][[1]]
                           } else {
                             ""
                           }
                         })
    batch_results <- data.frame(id = xml_text(xml_find_all(api_xml,"//section-data-set/id")),
                                gene_symbol = api_genes)
    results <- rbind(results, batch_results)
  }

  return(results)
}



mouse_organism_id <- 2
