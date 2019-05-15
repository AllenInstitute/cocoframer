get_aba_panel_ids <- function() {
  get_ids <- "http://api.brain-map.org/api/v2/data/query.csv?criteria=
     model::AtlasImage,
     rma::criteria,atlas_data_set(atlases[id$eq602630314]),graphic_objects(graphic_group_label[id$eq28]),
     rma::options[tabular$eq'sub_images.id'][order$eq'sub_images.id']
     &num_rows=all&start_row=0"

  get_ids <- gsub("[ \n]+","",get_ids)

  read.csv(url(get_ids))$id
}

get_atlas_svg <- function(ids,
                    downsample) {
  downsample <- as.character(downsample)

  id_urls <- paste0("http://api.brain-map.org/api/v2/svg/",
                    ids,
                    "?downsample=",downsample)

  in_con <- curl(id_urls, open = "r")
  svg_lines <- suppressWarnings(readLines(in_con))
  close(in_con)

  return(svg_lines)
}

get_atlas_svgs <- function(ids = NULL,
                           out_dir,
                           downsample = 4,
                           remove_colors = FALSE) {

  if(is.null(ids)) {
    ids <- get_aba_panel_ids()
  }

  for(i in 1:length(ids)) {
    svg_lines <- get_atlas_svg(ids[i])

    if(remove_colors) {
      svg_lines <- gsub("fill:#.{6}","fill:#ffffff",svg_lines)
    }

    out_con <- file(paste0(ids[i],".svg"), open = "w")
    writeLines(svg_lines, out_con)
    close(out_con)
  }

}

svg_to_tags <- function(x) {
  unlist(strsplit(x, "><"))
}

svg_tags_to_list <- function(x) {
  split_on_space <- unlist(strsplit(x,"\" "))
  no_quotes <- gsub("\"","",split_on_space)
  no_brackets <- sub("<g |path ","",no_quotes)
  split_on_eq <- strsplit(no_brackets, "=")

  out_list <- map(split_on_eq,
                  function(z) {
                    if(length(z) == 2) {
                      z[2]
                    } else {
                      out <- NA
                    }
                  })
  names(out_list) <- map_chr(split_on_eq, 1)

  out_list
}

svg_list_to_coords <- function(x) {
  if("d" %in% names(x)) {
    d <- sub("M ","",x$d)
    p <- unlist(strsplit(d, " L "))
    df <- map_dfr(p,
                  function(point) {
                    xy <- unlist(strsplit(point, ","))
                    data.frame(x = as.numeric(xy[1]),
                               y = as.numeric(xy[2]))
                  })

    # remove redundant points
    df <- df %>%
      filter(!(x == lag(x) & x == lead(x))) %>%
      filter(!(y == lag(y) & y == lead(y)))

    df
  } else {
    NULL
  }
}

svg_list_to_attr <- function(x) {
  keep <- names(x) != "d"
  out_list <- x[keep]
  if("style" %in% names(out_list)) {
    style <- out_list$style
    style <- gsub("/","",style)
    styles <- unlist(strsplit(style, ";"))
    color <- sub("stroke:","",styles[grepl("stroke:",styles)])
    fill <- sub("fill:","",styles[grepl("fill:",styles)])
    out_list$color <- color
    out_list$fill <- fill
  }
  out_list
}

svg_coords_to_segs <- function(df) {
  if(!is.null(df)) {

    points <- df

    segs <- data.frame(x = points$x,
                       y = points$y,
                       xend = lead(points$x),
                       yend = lead(points$y))

    segs <- segs[-nrow(segs),]

    last_seg <- data.frame(x = segs$xend[nrow(segs)],
                           y = segs$yend[nrow(segs)],
                           xend = segs$x[1],
                           yend = segs$y[1])

    segs <- rbind(segs, last_seg)
    segs
  }
}

plot_svg_coords <- function(svg_coords,
                            svg_attr,
                            min_pts = 20) {
  # remove nulls
  keep_coords <- !map_lgl(svg_coords, is.null)
  svg_coords <- svg_coords[keep_coords]
  svg_attr <- svg_attr[keep_coords]

  keep_coords <- map_int(svg_coords, nrow) >= min_pts
  svg_coords <- svg_coords[keep_coords]
  svg_attr <- svg_attr[keep_coords]

  plot_data <- map2_dfr(svg_coords,
                        svg_attr,
                        function(x, y) {
                          out <- x
                          out$fill <- y$fill
                          out$color <- y$color
                          out$id <- y$id
                          out$order <- y$order
                          out
                        })

  plot_list <- split(plot_data, plot_data$order)

  p <- ggplot() +
    scale_fill_identity() +
    scale_color_identity() +
    scale_y_reverse() +
    theme_void()

  for(i in 1:length(plot_list)) {
    p <- p +
      geom_polygon(data = plot_list[[i]],
                   aes(x = x,
                       y = y,
                       group = id,
                       fill = fill,
                       color = color))
  }

  p
}
