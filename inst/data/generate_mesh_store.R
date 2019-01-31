save_rgl_mesh_zip <- function(mesh,
                          mesh_name,
                          zip_file) {

  vb_vector <- as.vector(mesh$vb[1:3,])
  it_vector <- as.vector(mesh$it)

  out_vb_file <- paste0("vb_",mesh_name, ".num")
  out_it_file <- paste0("it_",mesh_name, ".int")

  temp_loc <- tempdir()

  writeBin(vb_vector, file.path(temp_loc, out_vb_file))
  writeBin(it_vector, file.path(temp_loc, out_it_file))

  zip(zip_file, c(file.path(temp_loc, out_vb_file),
                  file.path(temp_loc, out_it_file)))

  file.remove(file.path(temp_loc, out_vb_file))
  file.remove(file.path(temp_loc, out_it_file))
  file.remove(temp_loc)

}

mesh_source <- "http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/structure_meshes/"

