function Base.read(sdf::SDFFile, entry::String; units=true)
    open(sdf.name) do f
        block = sdf.blocks[entry]
        read_block(f, block, units)
    end
end

function Base.read(sdf::SDFFile, entries...; units=true)
    open(sdf.name) do f
        asyncmap(i -> read_block(f, sdf.blocks[i], units), entries)
    end
end

"""
    read_block(f::IO, block)

Read the block using a heuristic for determining the best API to use from SDFReader
"""
function read_block(f::IO, block::Union{PlainVariableBlockHeader,PointVariableBlockHeader}, units=true)
    max_size = 5000000
    if block_size(block) < max_size
        read(f, block)
    else
        raw_data = mmap_block(f, block)
        if units
            SDFReader.add_units(raw_data, block)
        else
            raw_data
        end
    end
end

function read_block(f::IO, block::PointMeshBlockHeader, units=true)
    raw_data = map(size(block)) do i
        mmap_block(f, block, i)
    end
    if units
        SDFReader.add_units(raw_data, block)
    else
        raw_data
    end
end

function read_block(f::IO, block::PlainMeshBlockHeader, units=true)
    make_grid(block, units)
end

read_block(io, block) = error("Unable to read $(nameof(block))")

function read_entry(io, sdf, name, units=true)
    blocks = sdf.blocks
    data_block = blocks[name]
    read_data_or_grid(data_block, blocks, io, units)
end

read_data_or_grid(data_block::T, blocks, io, units) where {T} = read_data_or_grid(data_kind(T), data_block, blocks, io, units)

function read_data_or_grid(::Data, data_block, blocks, io, units)
    data = read_block(io, data_block, units)
    grid = read_grid(io, data_block, blocks, units)
    store_entry(data_block, data, grid)
end

function read_data_or_grid(::Grid, data_block, blocks, io, units)
    grid = read_block(io, data_block, units)
    store_entry(discretization_type(typeof(grid)), grid)
end

store_entry(::Variable, data::NTuple) = ParticlePositions(data)
store_entry(data_block::T, data, grid) where {T} = store_entry(discretization_type(T), data_block, data, grid)

function store_entry(::StaggeredField, data_block, data, grid)
    name = nameof(data_block)
    ScalarField(data, grid, name)
end

function store_entry(::Variable, data_block, data, grid)
    name = nameof(data_block)
    ScalarVariable(data, grid, name)
end


# function read_expensive(sdf, ids)
#     open(sdf.name) do f
#         asyncmap(i -> make_grid(
#                 Variable(),
#                 sdf.blocks[i],
#                 nothing,
#                 f;
#                 cache=sdf.particle_cache[]
#             ), ids)
#     end
# end

function Base.getindex(sdf::SDFFile, name::String; units=true)
    open(sdf.name) do f
        read_entry(f, sdf, name, units)
    end
end

# function expensive_grids(ids, idx)
#     # Values corresponding to "grid/[species]") are expensive to read
#     cid = [ids...]
#     for (i, id) in enumerate(ids)
#         if isnothing(id) && occursin("grid/", string(idx[i]))
#             cid[i] = idx[i]
#         end
#     end
#     s_id = string.(cid)
#     expensive = map(i -> occursin("grid/", i), s_id)
#     !reduce(|, expensive) && return nothing, expensive
#     @debug "Found expensive to read mesh entries"
#     map(Symbol, unique(s_id[expensive])), expensive
# end

# The data for the particles is the most expensive to read since there are
# a lot of particles. Since the ScalarVariables have a grid, that grid
# might be the same for more variables and should only be read once
# function Base.getindex(sdf::SDFFile, idx::Vararg{Symbol,N}) where {N}
#     mesh_ids = get_mesh_id.((sdf,), idx)
#     @debug "Reading entries for $idx with mesh ids $mesh_ids"
#     expensive_ids, is_expensive = expensive_grids(mesh_ids, idx)
#     if isnothing(expensive_ids)
#         simple_read(sdf, idx)
#     else
#         @debug "Expensive idxs: $is_expensive"
#         @debug "Reading data without expensive grids"
#         partial_data = selective_read(sdf, idx, expensive_ids)
#         @debug "Reading expensive grids: $expensive_ids"
#         grids = read_expensive(sdf, expensive_ids)
#         grid_map = (; zip(expensive_ids, grids)...)
#         complete_data = ()
#         for (i, d) in enumerate(partial_data)
#             @debug "Is $(idx[i]) expensive? $(is_expensive[i])"
#             if is_expensive[i]
#                 id = mesh_ids[i]
#                 @debug "Expensive grid $id at $i"
#                 if isnothing(id)
#                     grid_id = idx[i]
#                     @debug "Storing grid entry $grid_id"
#                     grid = getproperty(grid_map, grid_id)
#                     complete_data = push!!(complete_data, grid)
#                 else
#                     @debug "Storing $id"
#                     grid = getproperty(grid_map, id)
#                     data = d.data
#                     data_block = d.block

#                     f = store_entry(data_block, data, grid)
#                     complete_data = push!!(complete_data, f)
#                 end
#             else
#                 complete_data = push!!(complete_data, d)
#             end
#         end
#         complete_data
#     end
# end

# function selective_read(sdf, idx, expensive_ids)
#     open(sdf.name) do f
#         asyncmap(i -> read_selected(f, sdf.blocks, i, expensive_ids), idx)
#     end
# end

# function simple_read(sdf, idx)
#     open(sdf.name) do f
#         asyncmap(i -> read_entry(f, sdf, i), idx)
#     end
# end
