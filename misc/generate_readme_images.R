library(cocoframer)
library(purrr)
library(rgl)

out_dir <- "man/figures"

structures <- c("root","CA")
mesh_list <- map(structures, ccf_2017_mesh)

names(mesh_list) <- structures

plot_ccf_meshes(mesh_list,
                fg_structure = "CA",
                bg_structure = "root")

snapshot3d(file.path(out_dir,
                     "readme_ca.png"))

clear3d()
plot_ccf_meshes(mesh_list,
                fg_structure = "CA",
                fg_color = "orangered",
                fg_alpha = 0.4,
                bg_structure = "root",
                bg_color = "yellow",
                bg_alpha = 0.4)

snapshot3d(file.path(out_dir,
                     "readme_ca_colors.png"))
clear3d()

structures <- c("root","TH","MOs","P")
mesh_list <- map(structures, ccf_2017_mesh)

names(mesh_list) <- structures

plot_ccf_meshes(mesh_list,
                fg_structure = c("MOs","TH","P"),
                fg_color = c("orangered","skyblue","purple"),
                bg_structure = "root")

snapshot3d(file.path(out_dir,
                     "readme_mo_th_p.png"))

clear3d()

th_str <- c("TH","LGd","LP","LGv","RT")
th_meshes <- map(th_str, ccf_2017_mesh)

names(th_meshes) <- th_str

plot_ccf_meshes(th_meshes,
                fg_structure = c("LGd","LGv","LP","RT"),
                fg_color = c("orangered","skyblue","purple","darkgreen"),
                bg_structure = c("TH"))

snapshot3d(file.path(out_dir,
                     "readme_within_th.png"))

clear3d()

structures <- c("root","MO","SS")
mesh_list <- map(structures, ccf_2017_mesh)
names(mesh_list) <- structures

plot_ccf_meshes(mesh_list,
                fg_structure = c("MO","SS"),
                bg_structure = "root",
                style = "shiny")

snapshot3d(file.path(out_dir,
                     "readme_shiny.png"))
clear3d()

plot_ccf_meshes(mesh_list,
                fg_structure = c("MO","SS"),
                bg_structure = "root",
                style = "matte")

snapshot3d(file.path(out_dir,
                     "readme_matte.png"))

clear3d()

plot_ccf_meshes(mesh_list,
                fg_structure = c("MO","SS"),
                bg_structure = "root",
                style = "cartoon")

snapshot3d(file.path(out_dir,
                     "readme_cartoon.png"))



structures <- c("root","TH","MOs","P")
mesh_list <- map(structures, ccf_2017_mesh)

names(mesh_list) <- structures

plot_ccf_meshes(mesh_list,
                fg_structure = c("MOs","TH","P"),
                bg_structure = "root")

anim <- spin3d(axis=c(0,1,0), # Spin on the y-axis
               rpm = 12)

movie3d(anim,
        fps = 20, # 20 fps is fairly smooth
        duration = 5, # 5 sec = 1 rotation at 12 rpm
        movie = "brain_demo", # Save as brain_demo.gif
        dir = "./", # Output directory - will make a lot of temporary files.
        type = "gif")
