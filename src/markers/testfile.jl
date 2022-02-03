# first activate geomIO
# ] activate <path/to/folder> or ] activate .

GeomIO_path = "/home/chris/Desktop/geomIO_mapview/geomIO"
conda_env = `conda activate /home/chris/Desktop/geomIO_mapview/geomIO/conda_env`

# activate geomIO package
using Pkg, Revise, Plots
Pkg.activate(GeomIO_path)

# activate conda environment that was created by PythonCall
# conda needs to be installed on system!!!!
run(conda_env, wait=false);

#using Conda
using geomIO

data = pygeomio.readSVG("subduction.svg");

# convert to normal coordinates
Ref,Coords,lP = pygeomio.getPoints2D("subduction.svg",10);

# extract Path Info information
xref, yref, PathCoords = ExtractPaths(Ref,Coords,lP)

# scale path Coords
#domain size (mapview)
Dxref = [0,1000]
Dyref = [0,500]
ScaledCoords = ScalePathCoords(Dxref,Dyref,xref,yref,PathCoords)

PathNames               = getLayerNames(data)

PathInfo = ConstPathObject(PathNames,ScaledCoords)


# plot path
display(plot(ScaledCoords[1][:,1],ScaledCoords[1][:,2]))
scatter!(ScaledCoords[2][:,1],ScaledCoords[2][:,2])
scatter!(ScaledCoords[3][:,1],ScaledCoords[3][:,2])

plotMapview(PathInfo)



