# Package dependencies:
# Sys.setenv(GITHUB_PAT = "9b82cd611afd98554b9753cb1e5df8e40e5012e2")
# devtools::install_github("AllenInstitute/cocoframer")
# devtools::install_github("AllenInstitute/scrattch.vis")
# install.packages(c("reshape2","dplyr","purrr","rbokeh","viridisLite"))

library(cocoframer)
library(purrr)
library(viridisLite) # optional - nice color palettes

# Get structure ontology annotations
ga <- get_ccf_grid_annotation()

ontology <- get_mba_ontology()
ontology_df <- flatten_mba_ontology(ontology)

# build a 3d array of ontology structure acronyms - easier to deal with than IDs
oa <- array(ontology_df$acronym[match(ga, ontology_df$id)], dim = dim(ga))

# Get ISH data
Slc17a7_ids <- get_gene_aba_ish_ids("Slc17a7")
Pvalb_ids <- get_gene_aba_ish_ids("Pvalb")
Sst_ids <- get_gene_aba_ish_ids("Sst")

# For now, we'll just take one of each - you could use more than 3 with ish_slice_heatmap_funs, below.
all_ids <- c(Slc17a7_ids[1], Pvalb_ids[1], Sst_ids[1])

all_data <- map(all_ids, get_aba_ish_data)

# Build heatmap plot with functions
# Note - the resolution of these datasets is 200 um per voxel/tile

# ish_slice_heatmap() gives you simple heatmaps for any single ISH dataset:
ish_slice_heatmap(all_data[[1]],
                  anno = oa,
                  direction = "coronal",
                  colorset = c("black","white"),
                  slice = 42)

ish_slice_heatmap(all_data[[2]],
                  anno = oa,
                  direction = "coronal",
                  colorset = viridis(10),
                  slice = 42)

ish_slice_heatmap(all_data[[3]],
                  anno = oa,
                  direction = "coronal",
                  colorset = c("white","orange","red"),
                  slice = 42)

# ish_slice_heatmap_funs() lets you apply functions to combine multiple ISH datasets
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
ish_slice_heatmap_3color(all_data[1:2],
                         anno = oa,
                         direction = "coronal",
                         slice_num = 42)

ish_slice_heatmap_3color(all_data[1:2],
                         anno = oa,
                         colors = c("green","blue"),
                         direction = "coronal",
                         slice_num = 42)

ish_slice_heatmap_3color(all_data,
                         anno = oa,
                         direction = "coronal",
                         slice_num = 42)

# You can also do any of these in horizontal or saggital slices:
ish_slice_heatmap_3color(all_data[1:2],
                         anno = oa,
                         direction = "horizontal",
                         slice_num = 15)

ish_slice_heatmap_funs(all_data,
                       anno = oa,
                       direction = "saggital",
                       slice_num = 20,
                       funs = c("+","+","+"))

