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

### Installation

cocoframer can be installed with:
```
devtools::install_github("AllenInstitute/cocoframer")
```

### Internet connection requirements

Some functions in cocoframer retrieve data from the Allen Brain Atlas API, and so require an internet connection.  

These functions are prefixed with `get_`.

### License

The license for this package is available on Github at: https://github.com/AllenInstitute/cocoframer/blob/master/LICENSE

### Level of Support

We are planning on occasional updating this tool with no fixed schedule. Community involvement is encouraged through both issues and pull requests.

### Contribution Agreement

If you contribute code to this repository through pull requests or other mechanisms, you are subject to the Allen Institute Contribution Agreement, which is available in full at: https://github.com/AllenInstitute/cocoframer/blob/master/CONTRIBUTION

