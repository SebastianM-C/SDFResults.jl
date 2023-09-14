function read_selected(file, blocks, name, skip_grid)
    data_block = getindex(blocks, name)
    # don't read grid for particles
    isnothing(get_mesh_id(data_block)) && return nothing
    data = read(file, data_block)

    if get_mesh_id(data_block) in skip_grid
        (data = data, block = data_block)
    else
        store_entry(data_block, data, file, blocks)
    end
end

get_cache(::Data, sdf) = sdf.cache[]
get_cache(::Grid, sdf) = sdf.particle_cache[]

store_entry(data_block::T, data, file, blocks) where {T} = store_entry(data_kind(T), data_block, data, file, blocks)

store_entry(::Grid, ::T, data, file, blocks) where {T} = store_entry(discretization_type(T), data)

function store_entry(::Data, data_block, data, file, blocks)
    mesh_block = getindex(blocks, get_mesh_id(data_block))
    grid = make_grid(mesh_block, data_block, file)

    @debug "Grid for data: $grid"
    store_entry(data_block, data, grid)
end

store_entry(data_block::T, data, grid) where {T} = store_entry(discretization_type(T), data_block, data, grid)

function store_entry(::StaggeredField, data_block, data, grid)
    name = nameof(data_block)
    ScalarField(data, grid, name)
end

function store_entry(::Variable, data_block, data, grid)
    name = nameof(data_block)
    ScalarVariable(data, grid, name)
end
