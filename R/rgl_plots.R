#' Plot a 3D CCF structure specified by its structure ID as points
#'
#' @param ccf_arr a CCF annotation array
#' @param structure_id The ID number of the desired CCF structure
#'
#' @return An rgl points3d plot
plot_ccf_structure_points <- function(ccf_arr,
                                      structure_id) {
  library(reshape2)
  library(rgl)

  vol_melt <- melt(ccf_arr)
  vol_melt <- vol_melt[vol_melt$value > 0,]

  if(!structure_id %in% unique(vol_melt$value)) {
    stop("Structure not found in ccf_arr.")
  }

  str_melt <- vol_melt[vol_melt$value == structure_id,]

  points3d(str_melt$Var1,str_melt$Var2,str_melt$Var3)

}

plot_brain_explorer_structures <- function(mesh_list,
                                           main_structure,
                                           main_color = "#74CAFF",
                                           main_alpha = 1,
                                           background_structure = NULL,
                                           background_color = "#808080",
                                           background_alpha = 0.2) {
  if(is.null(background_structure)) {
    meshes <- mesh_list[main_structure]
  } else {
    meshes <- mesh_list[c(main_structure,
                          background_structure)]

    meshes[[background_structure]]$material <- list(color = background_color,
                                                    alpha = background_alpha)
  }

  meshes[[main_structure]]$material <- list(color = main_color,
                                            alpha = main_alpha)

  rgl::view3d(theta = -45, phi = 35, zoom = 0.7)

  rgl::shapelist3d(meshes,
                   box = FALSE,
                   axes = FALSE,
                   xlab = "", ylab = "", zlab = "")
}
