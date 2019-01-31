# Mesh directory:
# http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/structure_meshes/ply/



obj_to_mesh <- function(obj,
                        material = "gray",
                        invert_y = TRUE,
                        yrange = c(0,1)) {

  obj_lines <- readLines(obj)

  vertex_lines <- obj_lines[grepl("^v ",obj_lines)]
  vertex_values <- as.numeric(unlist(strsplit(sub("v ","",vertex_lines)," ")))
  vertex_matrix <- t(matrix(vertex_values, nrow = length(vertex_lines), byrow = TRUE))

  if(invert_y) {
    midpoint <- (yrange[1] + yrange[2]) / 2
    vertex_matrix[2,] <- vertex_matrix[2,] + 2 * (midpoint - vertex_matrix[2,])
  }

  vertex_matrix <- rbind(vertex_matrix, rep(1, ncol(vertex_matrix)))


  face_lines <- obj_lines[grepl("^f ",obj_lines)]
  face_values <- as.integer(sub("//.+","",unlist(strsplit(sub("f ","",face_lines)," "))))
  face_matrix <- t(matrix(face_values, nrow = length(face_lines), byrow = TRUE))

  mesh <- list(vb = vertex_matrix, it = face_matrix, primitivetype = "triangle", material = material)
  class(mesh) <- c("mesh3d", "shape3d")

  mesh
}

plot_structure <- function(mesh_list,
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
