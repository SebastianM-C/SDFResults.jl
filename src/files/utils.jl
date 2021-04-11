get_parameter(sdf::SDFFile, p::Symbol) = getindex(sdf.param[], p)
get_parameter(sdf::SDFFile, p::Symbol, c::Symbol) = getindex(get_parameter(sdf, p), c)

get_time(sdf::SDFFile) = sdf.header.time * u"s"
get_npart(sdf::SDFFile, species) = sdf.blocks[Symbol("grid/"*species)].np

function Base.ndims(sdf::SDFFile)
    ks = string.(keys(sdf))
    i = findfirst(k->startswith(k, "grid"), ks)
    ndims(sdf.blocks[Symbol(ks[i])])
end

function domain_length(sdf::SDFFile, dir::Symbol)
    d_min = Symbol(string(dir)*"_min")
    d_max = Symbol(string(dir)*"_max")

    get_parameter(sdf, d_max) - get_parameter(sdf, d_min)
end

function domain_volume(sdf::SDFFile)
    nd = ndims(sdf)

    Δx = domain_length(sdf, :x)

    if ndims == 1
        Δx
    elseif ndims == 2
        Δy = domain_length(sdf, :y)
        Δx * Δy
    else
        Δy = domain_length(sdf, :y)
        Δz = domain_length(sdf, :z)
        Δx * Δy * Δz
    end
end

function cell_volume(sdf::SDFFile)
    nd = ndims(sdf)
    vol = domain_volume(sdf)
    nx = get_parameter(sdf, :nx)

    if ndims == 1
        vol / nx
    elseif ndims == 2
        ny = get_parameter(sdf, :ny)
        vol / (nx * ny)
    else
        ny = get_parameter(sdf, :ny)
        nz = get_parameter(sdf, :nz)
        vol / (nx * ny * nz)
    end
end

function cell_length(sdf::SDFFile, direction::Symbol)
    domain_length(sdf, direction)/get_parameter(sdf, Symbol("n"*"$direction"))
end
