# Package dependencies:
# Sys.setenv(GITHUB_PAT = "9b82cd611afd98554b9753cb1e5df8e40e5012e2")
# devtools::install_github("AllenInstitute/cocoframer")
# devtools::install_github("AllenInstitute/scrattch.vis")
# install.packages(c("reshape2","dplyr","purrr","rbokeh"))

library(cocoframer)
library(purrr)

# Get structure ontology annotations
ga <- get_ccf_grid_annotation()

ontology <- get_mba_ontology()
ontology_df <- flatten_mba_ontology(ontology)

# build a 3d array of ontology structures
oa <- array(ontology_df$acronym[match(ga, ontology_df$id)], dim = dim(ga))

# Get ISH data
Slc17a7_ids <- get_gene_aba_ish_ids("Slc17a7")
Pvalb_ids <- get_gene_aba_ish_ids("Pvalb")
Sst_ids <- get_gene_aba_ish_ids("Sst")

all_ids <- c(Slc17a7_ids[1], Pvalb_ids[1], Sst_ids[1])

all_data <- map(all_ids, get_aba_ish_data)

# Build heatmap plot with functions

# funs = c("+","+","+") will add all of the values for each gene.
ish_slice_heatmap_funs(all_data,
                     anno = oa,
                     direction = "coronal",
                     slice_num = 42,
                     funs = c("+","+","+"))

# You can get the difference between genes with "-".
# For example, you could subtract Pvalb and Sst from Slc17a7 to highlight Glutamatergic regions
ish_slice_heatmap_funs(all_data,
                       anno = oa,
                       direction = "coronal",
                       slice_num = 42,
                       funs = c("+","-","-"))

# Or multiply Pvalb and Sst to really highlight where they're coexpressed:
ish_slice_heatmap_funs(all_data[2:3],
                       anno = oa,
                       direction = "coronal",
                       slice_num = 42,
                       funs = c("+","*"))


# You can also make (up to) 3-color overlay heatmaps:
ish_slice_heatmap_3color(all_data,
                         anno = oa,
                         direction = "coronal",
                         slice_num = 42)
