struct SDFFile{P,B,C,PC}
    name::String
    header::Header
    blocks::B
    param::Ref{P}
    cache::Ref{C}
    particle_cache::Ref{PC}
end

include("read.jl")
include("utils.jl")
include("angular_momentum.jl")

Base.keys(sdf::SDFFile) = keys(sdf.blocks)
Base.getindex(sdf::SDFFile, idx::Vararg{AbstractString, N}) where N = sdf[Symbol.(idx)...]
Base.haskey(sim::SDFFile, key) = haskey(sim.param[], key)
Base.haskey(sim::SDFFile, block, key) = haskey(sim.param[][block], key)

# show
function Base.show(io::IO, ::MIME"text/plain", sdf::SDFFile)
    t = si_round(get_time(sdf))
    n = length(keys(sdf))
    print(io, "SDFFile with $n entries at t = " * t)
end
