#' Download the Mouse Brain Atlas ontology as a list object
#'
#' No parameters
#'
#' @return a nested list object containing the Mouse Brain Atlas ontology
#'
get_mba_ontology <- function() {
  library(jsonlite)

  # Download the ontology JSON file
  temp <- tempfile()
  download.file("http://api.brain-map.org/api/v2/structure_graph_download/1.json", temp)

  # Read the JSON
  raw_ontology <- fromJSON(temp)[["msg"]]

  return(raw_ontology)
}

#' Convert a nested Mouse Brain Atlas ontology to a data.frame
#'
#' @param ontology A nested ontology object
#' @param ongology_df An existing ontology data.frame. This is used for recursion. You should use the default, NULL, to extract a full ontology.
#'
#' @return a data.frame with all descriptive columns for the ontology.
#'
flatten_mba_ontology <- function(ontology, ontology_df = NULL) {
  library(purrr)

  l <- ontology

  if(is.null(ontology_df)) {
    ontology_df <- data.frame(l[names(l) != "children"])[0,]
    ontology_df$n_children <- numeric()
  }

  if("children" %in% names(l)) {

    child_df <- data.frame(l[names(l) != "children"])

    n_children_of_children <- map_dbl(l$children,
                                      function(x) {
                                        if("children" %in% names(x)) {
                                          length(x$children)
                                        } else {
                                          0
                                        }
                                      })

    child_df$n_children <- n_children_of_children

    ontology_df <- rbind(ontology_df, child_df)

    for(i in 1:length(l$children)) {

      child_list <- l$children[[i]]

      ontology_df <- flatten_mba_ontology(child_list, ontology_df)
    }
  }

  return(ontology_df)
}
