struct SDFFile{B}
    name::String
    header::Header
    blocks::B
end

function SDFFile(filename)
    h, blocks = open(file_summary, filename)
    SDFFile(filename, h, blocks)
end

include("read.jl")
include("grids.jl")
include("stagger.jl")
include("utils.jl")
include("angular_momentum.jl")

Base.keys(sdf::SDFFile) = keys(sdf.blocks)
# Base.haskey(sim::SDFFile, key) = haskey(sim.param[], key)
# Base.haskey(sim::SDFFile, block, key) = haskey(sim.param[][block], key)

# show
function Base.show(io::IO, ::MIME"text/plain", sdf::SDFFile)
    t = si_round(get_time(sdf))
    n = length(keys(sdf))
    print(io, "SDFFile with $n entries at t = " * t)
end
