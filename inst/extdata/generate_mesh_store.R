library(cocoframer)
library(xml2)
library(purrr)

obj_dir <- "http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/structure_meshes/"

obj_page <- read_html(obj_dir)

obj_links <- xml_find_all(obj_page, ".//a")
obj_files <- unlist(xml_attrs(obj_links, "href"))

obj_files <- obj_files[grepl(".obj$", obj_files)]

walk(obj_files,
     function(x) {
       download.file(file.path(obj_dir, x), x)
     })

obj_names <- sub(".obj","",obj_files)

walk(1:length(obj_files),
     function(x) {
       mesh <- obj_to_mesh(obj_files[x],
                           yrange = c(0, 8000))

       save_rgl_mesh_zip(mesh, obj_names[x], "ccf_2017_meshes.zip")
     })

library(dplyr)

ont <- flatten_mba_ontology(get_mba_ontology())

ont <- ont %>%
  mutate(color = paste0("#",color_hex_triplet))

ont <- ont[,c("id","acronym","name","color")]

write.csv(ont, "inst/extdata/mba_structure_id_to_acronym.csv", row.names = FALSE)
