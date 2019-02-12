#' Plot a 3D CCF structure specified by its structure ID as points
#'
#' @param ccf_arr a CCF annotation array
#' @param structure_id The ID number of the desired CCF structure
#'
#' @return An rgl points3d plot
plot_ccf_structure_points <- function(ccf_arr,
                                      structure_id) {

  vol_melt <- reshape2::melt(ccf_arr)
  vol_melt <- vol_melt[vol_melt$value > 0,]

  if(!structure_id %in% unique(vol_melt$value)) {
    stop("Structure not found in ccf_arr.")
  }

  str_melt <- vol_melt[vol_melt$value == structure_id,]

  rgl::points3d(str_melt$Var1,str_melt$Var2,str_melt$Var3)

}


#' Plot 3D structures of Brain explorer regions
#'
#' @param mesh_list a named list of one or more 3D mesh objects
#' @param fg_structure a
plot_brain_explorer_structures <- function(mesh_list,
                                           fg_structure,
                                           fg_color = "#74CAFF",
                                           fg_alpha = 1,
                                           bg_structure = NULL,
                                           bg_color = "#808080",
                                           bg_alpha = 0.2) {
  if(is.null(bg_structure)) {
    meshes <- mesh_list[fg_structure]
  } else {
    meshes <- mesh_list[c(fg_structure,
                          bg_structure)]

    meshes[[bg_structure]]$material <- list(color = bg_color,
                                                    alpha = bg_alpha)
  }

  meshes[[fg_structure]]$material <- list(color = fg_color,
                                            alpha = fg_alpha)

  rgl::view3d(theta = -45, phi = 35, zoom = 0.7)

  rgl::shapelist3d(meshes,
                   box = FALSE,
                   axes = FALSE,
                   xlab = "", ylab = "", zlab = "")
}
