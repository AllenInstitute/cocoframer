get_aba_panel_ids <- function() {
  get_ids <- "http://api.brain-map.org/api/v2/data/query.csv?criteria=
     model::AtlasImage,
     rma::criteria,atlas_data_set(atlases[id$eq602630314]),graphic_objects(graphic_group_label[id$eq28]),
     rma::options[tabular$eq'sub_images.id'][order$eq'sub_images.id']
     &num_rows=all&start_row=0"

  get_ids <- gsub("[ \n]+","",get_ids)

  read.csv(url(get_ids))$id
}

get_atlas_svgs <- function(ids = NULL,
                           out_dir,
                           downsample = 4,
                           remove_colors = FALSE) {

  if(is.null(ids)) {
    ids <- get_aba_panel_ids()
  }

  downsample <- as.character(downsample)

  id_urls <- paste0("http://api.brain-map.org/api/v2/svg/",
                    ids,
                    "?downsample=",downsample)

  for(i in 1:length(id_urls)) {
    in_con <- curl(id_urls[i], open = "r")
    svg_lines <- suppressWarnings(readLines(in_con))
    close(in_con)

    if(remove_colors) {
      svg_lines <- gsub("fill:#.{6}","fill:#ffffff",svg_lines)
    }

    out_con <- file(paste0(ids[i],".svg"), open = "w")
    writeLines(svg_lines, out_con)
    close(out_con)
  }

}
