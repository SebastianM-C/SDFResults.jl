get_parameter(sdf::SDFFile, p::Symbol) = getindex(sdf.param[], p)
get_parameter(sdf::SDFFile, p::Symbol, c::Symbol) = getindex(get_parameter(sdf, p), c)

get_time(sdf::SDFFile) = sdf.header.time * u"s"
get_npart(sdf::SDFFile, species) = sdf.blocks[Symbol("grid/"*species)].np

function Base.ndims(sdf::SDFFile)
    ks = string.(keys(sdf))
    i = findfirst(k->startswith(k, "grid"), ks)
    ndims(sdf.blocks[Symbol(ks[i])])
end

function get_data_description(file)
    h, blocks = open(file_summary, file)
    names = string.(keys(blocks))
    idx = findfirst(b->occursin("grid/", b), names)
    if isnothing(idx)
        @debug "No particle data found"
        N = 1
        T = Float64
    else
        N = ndims(blocks[Symbol(names[idx])])
        T = eltype(blocks[Symbol(names[idx])])
    end

    return N, T
end

get_mesh_id(block::AbstractBlockHeader) = hasproperty(block, :mesh_id) ? block.mesh_id : nothing

function get_mesh_id(file, idx)
    block = getindex(file.blocks, idx)
    get_mesh_id(block)
end
