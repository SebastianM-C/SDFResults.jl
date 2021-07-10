struct SDFFile{P,B,FC,PC}
    name::String
    header::Header
    blocks::B
    param::Ref{P}
    field_cache::Ref{FC}
    particle_cache::Ref{PC}
end

include("read.jl")
include("utils.jl")
include("angular_momentum.jl")

Base.keys(sdf::SDFFile) = keys(sdf.blocks)
Base.getindex(sdf::SDFFile, idx::Vararg{AbstractString, N}) where N = sdf[Symbol.(idx)...]
Base.haskey(sim::SDFFile, key) = haskey(sim.param[], key)
Base.haskey(sim::SDFFile, block, key) = haskey(sim.param[][block], key)
