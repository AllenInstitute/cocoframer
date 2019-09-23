# The cocoframer package
Functions for the Allen Institute's Mouse Common Coordinate Framework (CCF) in R.

### Functionality
cocoframer provides some limited funcitonality for using data from the Allen Brain Atlas that is registered to the Mouse Common Coordinate Framework.  

It currently assists:  
* Retrieving 3D, CCF aligned, gridded ISH data from the Allen Brain Atlas API  
* Rendering 2D plots of slices of ISH data  
* Retrieving the Mouse Brain Atlas structural ontology  
* Generating 3D plots of brain structures like those presented in the Allen Brain Explorer  

For additional data retrieval functionality beyond cocoframer, see the full Allen Brain Atlas API docs:  
http://help.brain-map.org/display/mousebrain/API  

For more information about the Allen Brain Atlas and the Common Coordinate Framework, see the Allen Brain Atlas website:  
http://atlas.brain-map.org/  

and the CCF documentation:  
http://help.brain-map.org/download/attachments/2818171/Mouse_Common_Coordinate_Framework.pdf  

An interactive, in-browser 3D structure viewer, the Allen Brain Explorer, is available here:  
http://connectivity.brain-map.org/3d-viewer?v=1

### Similar Tools

These tools also utilize the Allen Brain Atlas CCF to generate 3D rendering of mouse brains. They are not made by the Allen Institute for Brain Science, but provide additional funcitonality beyond what is currently available from `cocoframer`:

**In R:**  
The `mouselightr` package generates 3D CCF mouse brain plots, along with MouseLight neuron reconstructions:  
https://github.com/jefferis/nat.mouselight  
It 

**In Python:**  
`BrainRender` generates 3D CCF mouse brain plots, along with both Allen Connectivity Atlas and MouseLight neuron reconstructions:  
https://github.com/BrancoLab/BrainRender

### Installation

cocoframer can be installed with:
```
devtools::install_github("AllenInstitute/cocoframer")
```

### Citation

If you use cocoframer to access Allen Brain Atlas ISH Data, please cite:  
Lein, E.S. et al. (2007) Genome-wide atlas of gene expression in the adult mouse brain, Nature 445: 168-176. doi:10.1038/nature05453

If you use cocoframer to make your own 3D brain structure images and animations, please cite:  
© 2018 Allen Institute for Brain Science. Allen Brain Explorer. Available from: connectivity.brain-map.org/3d-viewer/

For other general citation issues, please refer to the Allen Institute Citation Policy: https://alleninstitute.org/legal/citation-policy/  

### Internet connection requirements

Some functions in cocoframer retrieve data from the Allen Brain Atlas API, and so require an internet connection.  

These functions are prefixed with `get_`.

### Examples

**Plotting a 3D brain structure**  

cocoframer includes 3D mesh objects from version 3 of the CCF (2017). These can be retrieved with cocoframer and plotted using the rgl package.  

In this example, we'll retrieve and plot the Hippocampal Amon's Horn (CA in the ABA structural ontology).
```
library(cocoframer)
library(rgl)

CA_mesh <- ccf_2017_mesh(acronym = "CA")

shapelist3d(CA_mesh)
```

**Plotting multiple 3D brain structures**  

To get some context, it's sometimes helpful to plot multiple structures.  

Here, we'll use a helper function included in cocoframer to plot the shell of the CCF (called root in the ABA structural ontology) with the CA:  
```
library(cocoframer)
library(purrr)
library(rgl)

structures <- c("root","CA")
mesh_list <- map(structures, ccf_2017_mesh)

names(mesh_list) <- structures

plot_ccf_meshes(mesh_list,
                fg_structure = "CA",
                bg_structure = "root")
```
![](man/figures/readme_ca.png?raw=true)

You can change the color and opacity of structures with additional parameters:

```
plot_ccf_meshes(mesh_list,
                fg_structure = "CA",
                fg_color = "orangered",
                fg_alpha = 0.4,
                bg_structure = "root",
                bg_color = "yellow",
                bg_alpha = 0.4)
```
![](man/figures/readme_ca_colors.png?raw=true)

It's straightforward to plot multiple structures, each with their own color:
```
library(cocoframer)
library(purrr)

structures <- c("root","TH","MOs","P")
mesh_list <- map(structures, ccf_2017_mesh)

names(mesh_list) <- structures

plot_ccf_meshes(mesh_list,
                fg_structure = c("MOs","TH","P"),
                fg_color = c("orangered","skyblue","purple"),
                bg_structure = "root")

```
![](man/figures/readme_mo_th_p.png?raw=true)

Of course, root doesn't have to be the background structure. Suppose you wanted to see how structures within the thalamus were positioned relative to each other:
```
th_str <- c("TH","LGd","LP","LGv","RT")
th_meshes <- map(th_str, ccf_2017_mesh)

names(th_meshes) <- th_str

plot_ccf_meshes(th_meshes,
                fg_structure = c("LGd","LGv","LP","RT"),
                fg_color = c("orangered","skyblue","purple","darkgreen"),
                bg_structure = c("TH"))

```
![](man/figures/readme_within_th.png?raw=true)

Cocoframer also provides a few built-in RGL material styles. The default is "shiny":
```
structures <- c("root","MO","SS")
mesh_list <- map(structures, ccf_2017_mesh)
names(mesh_list) <- structures

plot_ccf_meshes(mesh_list,
                fg_structure = c("MO","SS"),
                bg_structure = "root",
                style = "shiny")
```
![](man/figures/readme_shiny.png?raw=true)


This can be changed to "matte":
```
plot_ccf_meshes(mesh_list,
                fg_structure = c("MO","SS"),
                bg_structure = "root",
                style = "matte")
```
![](man/figures/readme_matte.png?raw=true)


Or "cartoon":
```
plot_ccf_meshes(mesh_list,
                fg_structure = c("MO","SS"),
                bg_structure = "root",
                style = "cartoon")
```
![](man/figures/readme_cartoon.png?raw=true)


**Saving 3D plot snapshots as images**  

Exporting an image for use in a figure is handled by the rgl package:
```
plot_ccf_meshes(mesh_list,
                fg_structure = c("MOs","TH","P"),
                fg_color = c("orangered","skyblue","purple"),
                bg_structure = "root")

rgl.snapshot("secondary_motor_and_targets.png")
```


And exporting each structure in a list can be accomplished with purrr::walk() :
```
library(cocoframer)
library(purrr)

structures <- c("root","TH","MOs","P")
mesh_list <- map(structures, ccf_2017_mesh)

names(mesh_list) <- structures

open3d()
walk(structures,
     function(structure) {
     
       clear3d()
       
       if(structure == "root") {
         plot_ccf_meshes(mesh_list,
                         main_structure = structure)
       } else {
         plot_ccf_meshes(mesh_list,
                         main_structure = structure,
                         background_structure = "root")
       }
       
       rgl.snapshot(paste0(structure,".png"))
     })
```
**Saving 3D plot objects as interactive HTML widgets**  

You can also save the interactive plot to HTML for later viewing in a web browser, with the assistance of the htmlwidgets package:
```
library(cocoframer)
library(purrr)
library(rgl)
library(htmlwidgets)

th_str <- c("TH","LGd","LP","LGv","RT")
th_meshes <- map(th_str, ccf_2017_mesh)

names(th_meshes) <- th_str

plot_ccf_meshes(th_meshes,
                fg_structure = c("LGd","LGv","LP","RT"),
                fg_color = c("orangered","skyblue","purple","darkgreen"),
                bg_structure = c("TH"))
                
th_widget <- rglwidget(scene3d(), # Captures the current 3D rgl plot
                       width = 600, 
                       height = 600)

saveWidget(th_widget, "th_structure_widget.html")
```

### Animations in rgl

The rgl package provides a robust framework for 3D animations. A simple example is making a spinning GIF of your brain structures of interest:
```
library(cocoframer)
library(purrr)

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
```
![](man/figures/rotate_demo.gif?raw=true)

### Common acronyms

These acronyms are used repeatedly in function names in cocoframer:  

aba: Allen Brain Atlas  
ccf: Common Coordinate Framework  
mba: Mouse Brain Atlas  
ish: In-Situ Hybridization  

### License

The license for this package is available on Github at: https://github.com/AllenInstitute/cocoframer/blob/master/LICENSE

### Level of Support

We are planning on occasional updating this tool with no fixed schedule. Community involvement is encouraged through both issues and pull requests.

### Contribution Agreement

If you contribute code to this repository through pull requests or other mechanisms, you are subject to the Allen Institute Contribution Agreement, which is available in full at: https://github.com/AllenInstitute/cocoframer/blob/master/CONTRIBUTION

