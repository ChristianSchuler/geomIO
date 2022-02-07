# first activate geomIO
# ] activate <path/to/folder> or ] activate .

GeomIO_path = "/home/chris/Desktop/geomIO_mapview/geomIO"
conda_env = `conda activate /home/chris/Desktop/geomIO_mapview/geomIO/conda_env`

#GeomIO_path = "/home/chris/Desktop/present_day_Alps/geomIO"
#conda_env = `conda activate /home/chris/Desktop/present_day_Alps/geomIO/conda_env`

# activate geomIO package
using Pkg, Revise
Pkg.activate(GeomIO_path)

# activate conda environment that was created by PythonCall
# conda needs to be installed on system!!!!
run(conda_env, wait=false);

#using Conda
using geomIO

const File = "subduction.svg" # filenmane
const prec = 10               # precision of routine that calculates coordinetes (getPoint2D)

#domain size (mapview)
const Dxref = [-500.0,500.0]
const Dyref = [-1000.0,-500.0]

# put scaled Path Information into PathObject struct
PathInfo  = ConstPathObject(File,prec,Dxref,Dyref)

# plot svg info
plotMapview(PathInfo)



















