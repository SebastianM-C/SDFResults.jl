function read_grid(io, data_block, blocks, units=true)
    id = get_mesh_id(data_block)
    mesh_block = blocks[id]

    make_grid(mesh_block, data_block, io, units)
end

function make_grid(mesh_block, units)
    if units
        u = get_units(mesh_block.units)
    else
        u = true
    end
    minval = mesh_block.minval .* u
    maxval = mesh_block.maxval .* u
    dims = mesh_block.dims

    map(eachindex(dims)) do i
        range(minval[i], maxval[i], length=dims[i])
    end
end

make_grid(mesh_block::T, data_block, file, units) where {T} =
    make_grid(discretization_type(T), mesh_block, data_block, file, units)

function make_grid(::StaggeredField, mesh_block, data_block, file, units)
    original_grid = make_grid(mesh_block, units)
    @debug "Creating grid from $original_grid"

    stagger = data_block.stagger
    @debug "Staggering: $stagger"
    grid = apply_stagger(original_grid, Val(stagger))

    # Fix grid in the cases where it doesn't match the data. See
    # https://cfsa-pmw.warwick.ac.uk/SDF/SDF_C/-/blob/master/src/sdf_control.c#L775-780
    for i in axes(grid)[1]
        if length(grid[i]) ≠ data_block.dims[i]
            grid = setindex!!(grid, grid[i][begin:end-1], i)
        end
    end

    names = Symbol.(lowercase.(labels(mesh_block)))
    @debug "Axis label names: $names"

    return SparseAxisGrid(grid; names)
end

function make_grid(::Variable, mesh_block, data_block, file, units)
    grid = read_block(file, mesh_block)

    units = get_units(mesh_block.units)
    if units
        u = get_units(mesh_block.units)
    else
        u = true
    end

    minvals = (mesh_block.minval...,) .* u
    maxvals = (mesh_block.maxval...,) .* u

    names = Symbol.(lowercase.(labels(mesh_block)))
    @debug "Axis label names: $names"

    ParticlePositions(grid; names, mins=MVector(minvals), maxs=MVector(maxvals))
end
