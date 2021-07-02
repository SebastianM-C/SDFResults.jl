get_parameter(sdf::SDFFile, p::Symbol) = getindex(sdf.param[], p)
get_parameter(sdf::SDFFile, p::Symbol, c::Symbol) = getindex(get_parameter(sdf, p), c)

get_time(sdf::SDFFile) = sdf.header.time * u"s"
get_npart(sdf::SDFFile, species) = sdf.blocks[Symbol("grid/"*species)].np

function Base.ndims(sdf::SDFFile)
    ks = string.(keys(sdf))
    i = findfirst(k->startswith(k, "grid"), ks)
    ndims(sdf.blocks[Symbol(ks[i])])
end
