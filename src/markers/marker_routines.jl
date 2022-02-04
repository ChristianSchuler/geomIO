using Plots

export PathObject,ExtractPaths, getLayerNames, ConstPathObject, ScalePathCoords, plotMapview

"""
struct that contains all neccessary iformation about the different paths
"""

mutable struct PathObject
    Pathnames :: Tuple
    Coords    :: NamedTuple
    Ref       :: NamedTuple
end

function ScalePathCoords(Dxref,Dyref,xref,yref,PathCoords)

    # shift Coordinates so that the origin is 0,0

    for i = 1:length(PathCoords)

        PathCoords[i][:,1] .-= xref[1]
        PathCoords[i][:,2] .-= yref[1]

        # scale the Coordinates so that they range from 0 to 1 in x and y direction
        PathCoords[i][:,1] ./= (abs(xref[2]-xref[1]))
        PathCoords[i][:,2] ./= (abs(yref[2]-yref[1]))

        # crop area to domain size

        for j = 1:length(PathCoords[i][:,1])

            if (maximum(PathCoords[i][:,2]) > xref[2] || maximum(PathCoords[i][:,1]) > yref[2] || minimum(PathCoords[i][:,1]) > xref[1] || minimum(PathCoords[i][:,1]) > xref[1])

                # check y values
                if PathCoords[i][j,1] < 0
                    PathCoords[i][j,1] = 0
                elseif PathCoords[i][j,1] > 1
                    PathCoords[i][j,1] = 1
                end

                #check x values
                if PathCoords[i][j,2] < 0
                    PathCoords[i][j,2] = 0
                elseif PathCoords[i][j,2] > 1
                    PathCoords[i][j,2] = 1
                end

            end

        end

        # consider the domain size scale the coordinates accordingly
        # WARNING needs to be adapted for domains not starting at 0!!!!!
        PathCoords[i][:,1] .*= Dxref[2]
        PathCoords[i][:,2] .*= Dyref[2]

    end

    return PathCoords

end

"""
Constructur for PathInfo
"""
function ConstPathObject(strings::Vector{String},paths::Vector{Any},RefD::NamedTuple{(:x, :y), Tuple{Vector{Int64}, Vector{Int64}}})

    # convert to name and coord info to NamedTuple

    s = Tuple(Symbol(strings[i]) for i = 1:length(strings)) # also creating symbols out of strings
    p = Tuple(paths[i] for i = 1:length(paths))

    PathInfo = PathObject(Tuple(strings),NamedTuple{s}(p),RefD)

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
    display(plot(PathInfo.Coords[length(PathInfo.Coords)][:,1],PathInfo.Coords[length(PathInfo.Coords)][:,2],fill=0,aspect_ratio=1,label=PathInfo.Pathnames[nP],legend=:outerright,grid=false,xlims=(minimum(PathInfo.Ref.x),maximum(PathInfo.Ref.x)),ylims = (minimum(PathInfo.Ref.y),maximum(PathInfo.Ref.y))))

    for i = 1:length(PathInfo.Coords)-1

        if cmp(PathInfo.Pathnames[nP-i],"trench") == 1
            display(plot!(PathInfo.Coords[nP-i][:,1],PathInfo.Coords[nP-i][:,2],linewidth=4,label=PathInfo.Pathnames[nP-i]))

        else
            display(plot!(PathInfo.Coords[nP-i][:,1],PathInfo.Coords[nP-i][:,2],fill=0,label=PathInfo.Pathnames[nP-i]))

        end

    end


end
