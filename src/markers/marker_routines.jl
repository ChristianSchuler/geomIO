using Plots

export PathObject,ExtractPaths, getLayerNames, ConstPathObject, ScalePathCoords, plotMapview

"""
struct that contains all neccessary iformation about the different paths
"""

struct PathObject
    Pathnames :: Tuple
    Coords    :: NamedTuple
    Ref       :: NamedTuple
end

function ScalePathCoords(Dxref::Vector{Float64},Dyref::Vector{Float64},xref::Vector{Float64},yref::Vector{Float64},PathCoords::Vector{Any})

    Dy_diff = abs(Dyref[2] - Dyref[1])
    Dx_diff = abs(Dxref[2] - Dxref[1])

    # shift Coordinates so that the origin is 0,0
    for i = 1:length(PathCoords)

        PathCoords[i][:,1]  .-= xref[1]
        PathCoords[i][:,2]  .-= yref[1]

        # scale the Coordinates so that they range from 0 to 1 in x and y direction
        PathCoords[i][:,1]  ./= (abs(xref[2]-xref[1]))
        PathCoords[i][:,2]  ./= (abs(yref[2]-yref[1]))

        # crop area to domain size

        for j = 1:length(PathCoords[i][:,1])

            if (maximum(PathCoords[i][:,2]) > xref[2] || maximum(PathCoords[i][:,1]) > yref[2] || minimum(PathCoords[i][:,1]) > xref[1] || minimum(PathCoords[i][:,1]) > xref[1])

                # check y values
                if PathCoords[i][j,1] < 0.0
                    PathCoords[i][j,1] = 0.0
                elseif PathCoords[i][j,1] > 1
                    PathCoords[i][j,1] = 1.0
                end

                # check x values
                if PathCoords[i][j,2] < 0.0
                    PathCoords[i][j,2] = 0.0
                elseif PathCoords[i][j,2] > 1
                    PathCoords[i][j,2] = 1.0
                end

            end

        end

        # consider the domain size  and scale the coordinates accordingly

        #PathCoords[i][:,1] .*= abs(Dxref[2] - Dxref[1])
        #PathCoords[i][:,2] .*= abs(Dyref[2] - Dyref[1])
        PathCoords[i][:,1] .*= Dx_diff
        PathCoords[i][:,2] .*= Dy_diff

        PathCoords[i][:,1] .+= Dxref[1]
        PathCoords[i][:,2] .+= Dyref[1]

    end

    return PathCoords

end

"""
Constructur for PathInfo
"""
function ConstPathObject(File::String,prec::Int,Dxref::Vector{Float64},Dyref::Vector{Float64})

    # read svg file
    data = pygeomio.readSVG(File)
    PathNames = getLayerNames(data)

    # get coordinates
   Ref,Coords,lP = pygeomio.getPoints2D(File,prec)

    # error catching; verify the Reference line
    Ref1 = pyconvert(Float64,Ref[1,0])
    Ref2 = pyconvert(Float64,Ref[1,1])

    if ( typeof(Ref1)<:Float64 || typeof(Ref2)<:Float64 ) == false
        error("something wrong with the reference line")
    end

    # extract Path Info information
    xref, yref, PathCoords = ExtractPaths(Ref,Coords,lP)

    # scale coordinates
    ScaledCoords = ScalePathCoords(Dxref,Dyref,xref,yref,PathCoords)

    RefD = NamedTuple{Tuple([:x,:y])}(Tuple([Dxref,Dyref]))

    # convert to name and coord info to NamedTuple

    s = Tuple(Symbol(PathNames[i]) for i = 1:length(PathNames)) # also creating symbols out of strings
    p = Tuple(ScaledCoords[i] for i = 1:length(ScaledCoords))

    PathInfo = PathObject(Tuple(PathNames),NamedTuple{s}(p),RefD)

    return PathInfo

end 

"""
returns array of path name strings, order is important!
"""
function getLayerNames(data::PythonCall.Py)

    namesP    = pyconvert(Vector{String},data.CurveNames) # names of paths
    namesL    = pyconvert(Vector{String},data.LayerNames) # names of layers

    namesList = String[]

    for (ind,name) in enumerate(namesP)

        if namesL[ind] == "Layers"   # ensures that the current path refers to Layer "Layers"
            
            push!(namesList,name)

        end

    end

    return namesList

end

"""
Extract and arrange Path Information
"""
function ExtractPaths(Ref::PythonCall.Py,Coords::PythonCall.Py,lP::PythonCall.Py)

    # convert python structs to Julia arrays
    Ref    = pyconvert(Matrix{Float64},Ref)
    Coords = pyconvert(Matrix{Float64},Coords)
    lP     = pyconvert(Array{Int64},lP)

    # extract maximum and minimum coordinates
    Xref = [minimum(Ref[:,1]),maximum(Ref[:,1])]
    Yref = [minimum(Ref[:,2]),maximum(Ref[:,2])]

    #Refnt = NamedTuple{Tuple([:x,:y])}(Tuple([Xref,Yref]))
    append!(lP,0)
    lP        = reverse(lP)
    Coords    = reverse(Coords,dims=1)
    LayersPath = []
    for ind = 1:length(lP)-1

        push!(LayersPath,Coords[lP[ind]+1:lP[ind+1],:])
        
    end

    return Xref, Yref, LayersPath

end


function plotMapview(PathInfo::PathObject)

    nP = length(PathInfo.Coords) # number of paths
    p  = plot(PathInfo.Coords[length(PathInfo.Coords)][:,1],PathInfo.Coords[length(PathInfo.Coords)][:,2],fill=0,aspect_ratio=1,label=PathInfo.Pathnames[nP],legend=:outerright,grid=false,xlims=(minimum(PathInfo.Ref.x),maximum(PathInfo.Ref.x)),ylims = (minimum(PathInfo.Ref.y),maximum(PathInfo.Ref.y)))

    for i = 1:length(PathInfo.Coords)-1

        if cmp(PathInfo.Pathnames[nP-i],"trench") == 1
            p = plot!(PathInfo.Coords[nP-i][:,1],PathInfo.Coords[nP-i][:,2],linewidth=4,label=PathInfo.Pathnames[nP-i])

        else
            p = plot!(PathInfo.Coords[nP-i][:,1],PathInfo.Coords[nP-i][:,2],fill=0,label=PathInfo.Pathnames[nP-i])

        end

    end

    display(p)

end
