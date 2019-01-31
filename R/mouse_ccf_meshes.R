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

save_rgl_mesh_zip <- function(mesh,
                              mesh_name,
                              zip_file) {

  vb_vector <- as.vector(mesh$vb[1:3,])
  it_vector <- as.vector(mesh$it)

  out_vb_file <- paste0("vb_",mesh_name, ".num")
  out_it_file <- paste0("it_",mesh_name, ".int")

  temp_loc <- tempdir()

  out_vb <- file(file.path(temp_loc, out_vb_file), open = "wb")
  out_it <- file(file.path(temp_loc, out_it_file), open = "wb")

  writeBin(as.integer(length(vb_vector) / 3), out_vb)
  writeBin(as.integer(length(it_vector) / 3), out_it)

  writeBin(vb_vector, out_vb)
  writeBin(it_vector, out_it)

  close(out_vb)
  close(out_it)

  zip(zip_file, c(file.path(temp_loc, out_vb_file),
                  file.path(temp_loc, out_it_file)),
      extras = "-j")

  file.remove(file.path(temp_loc, out_vb_file))
  file.remove(file.path(temp_loc, out_it_file))

}

read_rgl_mesh_zip <- function(mesh_name,
                              zip_file,
                              material = "gray") {

  vb_file <- paste0("vb_", mesh_name, ".num")
  it_file <- paste0("it_", mesh_name, ".int")

  in_vb <- unz(zip_file, vb_file, open = "rb")
  in_it <- unz(zip_file, it_file, open = "rb")

  n_vb <- readBin(in_vb, "integer", n = 1) * 3
  n_it <- readBin(in_it, "integer", n = 1) * 3

  vb_vector <- readBin(in_vb, "numeric", n = n_vb)
  it_vector <- readBin(in_it, "integer", n = n_it)

  vb_mat <- matrix(vb_vector, nrow = 3)
  it_mat <- matrix(it_vector, nrow = 3)

  vb_mat <- rbind(vb_mat, rep(1, ncol(vb_mat)))

  mesh <- list(vb = vb_mat, it = it_mat, primitivetype = "triangle", material = material)
  class(mesh) <- c("mesh3d", "shape3d")

  mesh

}

