# first activate geomIO
# ] activate <path/to/folder> or ] activate .

#GeomIO_path = "/home/chris/Desktop/geomIO_mapview/geomIO"
#conda_env = `conda activate /home/chris/Desktop/geomIO_mapview/geomIO/conda_env`

GeomIO_path = "/home/chris/Desktop/present_day_Alps/geomIO"
conda_env = `conda activate /home/chris/Desktop/present_day_Alps/geomIO/conda_env`

# activate geomIO package
using Pkg, Revise
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
RefD = NamedTuple{Tuple([:x,:y])}(Tuple([Dxref,Dyref]))
ScaledCoords = ScalePathCoords(Dxref,Dyref,xref,yref,PathCoords)

PathNames = getLayerNames(data)

PathInfo  = ConstPathObject(PathNames,ScaledCoords,RefD)

# plot svg info
plotMapview(PathInfo)



