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


slice_ccf_mat <- function(mat,
                         slice_num,
                         direction = "coronal") {


  if(direction == "coronal") {
    return(mat[slice_num, , ])
  }
  if(direction == "horizontal") {
    return(mat[, slice_num, ])
  }
  if(direction == "saggital") {
    return(mat[, , slice_num])
  }
}

ish_slice_heatmap <- function(mat,
                              anno = NULL,
                              slice_num,
                              direction = "coronal",
                              normalize = "slice",
                              colorset = c("darkblue","gray90","red")) {

  library(rbokeh)
  library(dplyr)
  library(reshape2)
  library(scrattch.vis)

  slice_mat <- slice_ccf_mat(mat, slice_num, direction)

  if(normalize == "slice") {
    max_val <- max(slice_mat)
  } else if(normalize == "all") {
    max_val <- max(mat)
  }

  slice_flat <- melt(slice_mat)
  names(slice_flat) <- c("y","x","value")

  slice_flat$value[slice_flat$value < 0] <- 0
  slice_flat$color <- values_to_colors(slice_flat$value,
                                       colorset = colorset,
                                       min_val = 0,
                                       max_val = max_val)

  if(is.null(anno)) {
    hover_list <- list("Value" = "value")
  } else {
    anno_flat <- melt(slice_ccf_mat(anno, slice_num, direction))
    names(anno_flat) <- c("y","x","annotation")
    slice_flat <- left_join(slice_flat, anno_flat, by = c("x","y"))
    hover_list <- list("Value" = "value",
                       "Annotation" = "annotation")
  }

  if(direction == "coronal") {
    f <- figure(width = dim(slice_mat)[2]*10,
                height = dim(slice_mat)[1]*10) %>%
      ly_crect(data = slice_flat,
               x = x,
               y = -y,
               fill_color = color,
               line_color = NA,
               fill_alpha = 1,
               hover = hover_list)
  } else if(direction == "horizontal") {
    f <- figure(width = dim(slice_mat)[1]*10,
                height = dim(slice_mat)[2]*10) %>%
      ly_crect(data = slice_flat,
               x = y,
               y = x,
               fill_color = color,
               line_color = NA,
               fill_alpha = 1,
               hover = hover_list)
  } else if(direction == "saggital") {
    f <- figure(width = dim(slice_mat)[1]*10,
                height = dim(slice_mat)[2]*10) %>%
      ly_crect(data = slice_flat,
               x = y,
               y = -x,
               fill_color = color,
               line_color = NA,
               fill_alpha = 1,
               hover = hover_list)
  }

  return(f)


}


ish_slice_heatmap_3color <- function(mat_list,
                                     anno = NULL,
                               slice_num,
                               colors = c("#FF0000","#00FF00","#0000FF"),
                               direction = "coronal",
                               normalize = "slice",
                               scale = "linear") {

  library(rbokeh)
  library(reshape2)
  library(purrr)
  library(dplyr)
  library(scrattch.vis)

  slice_mat_list <- map(mat_list, slice_ccf_mat, slice_num, direction)

  slice_mat_list <- map(slice_mat_list,
                        function(x) {
                          x[x < 0] <- 0
                          x
                        })

  if(scale == "log10") {
    slice_mat_list <- map(slice_mat_list, function(x) { log10(x + 1) })
  }

  if(normalize == "slice") {
    max_vals <- map_dbl(slice_mat_list, max)
  } else if(normalize == "all") {
    max_vals <- map_dbl(mat_list, max)
  }

  slice_flat_list <- map(slice_mat_list,
                         function(slice_mat) {
                           slice_flat <- melt(slice_mat)
                           names(slice_flat) <- c("y","x","value")
                           slice_flat
                         })

  if(length(slice_flat_list) > 0) {
    slice_flat_list[[1]]$color1 <- values_to_colors(slice_flat_list[[1]]$value,
                                                   min_val = 0,
                                                   max_val = max_vals[1],
                                                   colorset = c("#000000", colors[1]))

    slice_flat <- slice_flat_list[[1]][,c("x","y","color1")]

    slice_flat$color <- slice_flat$color1
  }

  if(length(slice_flat_list) > 1) {
    slice_flat_list[[2]]$color2 <- values_to_colors(slice_flat_list[[2]]$value,
                                                   min_val = 0,
                                                   max_val = max_vals[2],
                                                   colorset = c("#000000", colors[2]))

    slice_flat <- full_join(slice_flat,
                            slice_flat_list[[2]][,c("x","y","color2")],
                            by = c("x","y"))

    slice_flat$color[is.na(slice_flat$color1)] <- "#000000"
    slice_flat$color2[is.na(slice_flat$color2)] <- "#000000"

    slice_flat$color <- map2_chr(slice_flat$color, slice_flat$color2, color_sum)
  }

  if(length(slice_flat_list) > 2) {
    slice_flat_list[[3]]$color3 <- values_to_colors(slice_flat_list[[3]]$value,
                                                   min_val = 0,
                                                   max_val = max_vals[3],
                                                   colorset = c("#000000", colors[3]))

    slice_flat <- full_join(slice_flat,
                            slice_flat_list[[3]][,c("x","y","color3")],
                            by = c("x","y"))

    slice_flat$color[is.na(slice_flat$color1)] <- "#000000"
    slice_flat$color3[is.na(slice_flat$color3)] <- "#000000"
    slice_flat$color <- map2_chr(slice_flat$color, slice_flat$color3, color_sum)

  }


  if(is.null(anno)) {
    hover_list <- list("Value" = "color")
  } else {
    anno_flat <- melt(slice_ccf_mat(anno, slice_num, direction))
    names(anno_flat) <- c("y","x","annotation")
    slice_flat <- left_join(slice_flat, anno_flat, by = c("x","y"))
    hover_list <- list("Value" = "color",
                       "Annotation" = "annotation")
  }

  if(direction == "coronal") {
    f <- figure(width = dim(slice_mat_list[[1]])[2]*10,
                height = dim(slice_mat_list[[1]])[1]*10) %>%
      ly_crect(data = slice_flat,
                  x = x,
                  y = -y,
                  fill_color = color,
                  line_color = NA,
                  fill_alpha = 1,
                  hover = hover_list)
  } else if(direction == "horizontal") {
    f <- figure(width = dim(slice_mat_list[[1]])[1]*10,
                height = dim(slice_mat_list[[1]])[2]*10) %>%
      ly_crect(data = slice_flat,
               x = y,
               y = x,
               fill_color = color,
               line_color = NA,
               fill_alpha = 1,
               hover = hover_list)
  } else if(direction == "saggital") {
    f <- figure(width = dim(slice_mat_list[[1]])[1]*10,
                height = dim(slice_mat_list[[1]])[2]*10) %>%
      ly_crect(data = slice_flat,
               x = y,
               y = -x,
               fill_color = color,
               line_color = NA,
               fill_alpha = 1,
               hover = hover_list)
  }

  return(f)

}

ish_slice_heatmap_funs <- function(mat_list,
                                   anno = NULL,
                                   slice_num,
                                   funs,
                                   colorset = c("#000000","#FFFFFF"),
                                   direction = "coronal",
                                   normalize = "slice",
                                   scale = "linear") {

  library(rbokeh)
  library(reshape2)
  library(purrr)
  library(dplyr)
  library(scrattch.vis)

  slice_mat_list <- map(mat_list, slice_ccf_mat, slice_num, direction)

  slice_mat_list <- map(slice_mat_list,
                        function(x) {
                          x[x < 0] <- 0
                          x
                        })

  if(scale == "log10") {
    slice_mat_list <- map(slice_mat_list, function(x) { log10(x + 1) })
  }

  if(normalize == "slice") {
    max_vals <- map_dbl(slice_mat_list, max)
  } else if(normalize == "all") {
    max_vals <- map_dbl(mat_list, max)
  }

  slice_mat_list <- map2(slice_mat_list,
                         max_vals,
                         function(x, y) { x / y })

  slice_mat <- slice_mat_list[[1]]
  slice_mat[slice_mat > 0] <- 0

  for(i in 1:length(slice_mat_list)) {
    slice_mat <- eval(call(funs[i], slice_mat, slice_mat_list[[i]]))
  }

  slice_flat <- melt(slice_mat)
  names(slice_flat) <- c("y","x","value")
  slice_flat$color <- values_to_colors(slice_flat$value,
                                       colorset = colorset)

  slice_flat$value <- round(slice_flat$value, 3)

  if(is.null(anno)) {
    hover_list <- list("Value" = "value")
  } else {
    anno_flat <- melt(slice_ccf_mat(anno, slice_num, direction))
    names(anno_flat) <- c("y","x","annotation")
    slice_flat <- left_join(slice_flat, anno_flat, by = c("x","y"))
    hover_list <- list("Value" = "value",
                       "Annotation" = "annotation")
  }

  if(direction == "coronal") {
    f <- figure(width = dim(slice_mat_list[[1]])[2]*10,
                height = dim(slice_mat_list[[1]])[1]*10) %>%
      ly_crect(data = slice_flat,
               x = x,
               y = -y,
               fill_color = color,
               line_color = NA,
               fill_alpha = 1,
               hover = hover_list)
  } else if(direction == "horizontal") {
    f <- figure(width = dim(slice_mat_list[[1]])[1]*10,
                height = dim(slice_mat_list[[1]])[2]*10) %>%
      ly_crect(data = slice_flat,
               x = y,
               y = x,
               fill_color = color,
               line_color = NA,
               fill_alpha = 1,
               hover = hover_list)
  } else if(direction == "saggital") {
    f <- figure(width = dim(slice_mat_list[[1]])[1]*10,
                height = dim(slice_mat_list[[1]])[2]*10) %>%
      ly_crect(data = slice_flat,
               x = y,
               y = -x,
               fill_color = color,
               line_color = NA,
               fill_alpha = 1,
               hover = hover_list)
  }

  return(f)
}
mouse_organism_id <- 2
