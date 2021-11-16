module geomIO

# Force using conda python installation
ENV["PYTHON"]=""
using Pkg
Pkg.add("PyCall")

using  Conda, PyCall
export pygeomio

@show PyCall.pyversion, PyCall.libpython, PyCall.conda

const pygeomio = PyNULL()

function __init__()

    # Load the required python packages (installs them in the local conda installation if required)
    chn     =   "conda-forge"
    Conda.add("svgpathtools",   :my_env, channel=chn)
    Conda.add("numpy",          :my_env, channel=chn)
    Conda.add("numpy-stl",      :my_env, channel=chn)
    Conda.add("matplotlib",     :my_env, channel=chn)
    Conda.add("scipy",          :my_env, channel=chn)
    Conda.add("ipdb",           :my_env, channel=chn)
    Conda.add("vtk",            :my_env, channel=chn)

  #  pushfirst!(PyVector(pyimport("sys")["path"]), (PROJECT_ROOT)*"/python")
    pushfirst!(PyVector(pyimport("sys")["path"]), (@__DIR__)*"/python")  # relative to /src of geomIO
    copy!(pygeomio, pyimport("geomio"))

end

include("./geomIO_routines.jl")




end # module
