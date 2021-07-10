struct EPOCHSimulation{P,B,FC,PC}
    dir::String
    files::Vector{SDFFile{P,B,FC,PC}}
    param::P
    field_cache::FC
    particle_cache::PC
end

function read_simulation(dir; field_cache_size=6, particle_cache_size=2, kwargs...)
    file_list = joinpath(dir, "normal.visit")
    if isfile(file_list)
        paths = readlines(file_list)
    else
        @debug "No normal.visit found in $dir."
        paths = filter(f->endswith(f, ".sdf"), readdir(dir))
    end

    input_deck = joinpath(dir, "input.deck")
    if isfile(input_deck)
        p = parse_input(input_deck)
    else
        @warn "No input.deck found in $dir."
        p = missing
    end

    # We assume that the particle_cache has the same dimensionality throughout
    # all the simulation, so we ca use the first file to get the dimensionality
    # and element type

    N, T = get_data_description(joinpath(dir, first(paths)))
    @debug "First file gave N = $N and T = $T"

    field_cache = LRU{Tuple{String,AbstractBlockHeader},AbstractArray}(maxsize=field_cache_size, kwargs...)
    particle_cache =  LRU{Tuple{String,AbstractBlockHeader},NTuple{N,Vector{T}}}(maxsize=particle_cache_size)

    files = read_file.(joinpath.((dir,), paths), (Ref(p),), (Ref(field_cache),), (Ref(particle_cache),))

    EPOCHSimulation(dir, files, p, field_cache, particle_cache)
end

# Indexing
Base.getindex(sim::EPOCHSimulation, i::Int) = sim.files[i]
Base.firstindex(sim::EPOCHSimulation) = firstindex(sim.files)
Base.lastindex(sim::EPOCHSimulation) = lastindex(sim.files)

# Iteration
Base.iterate(sim::EPOCHSimulation, state...) = iterate(sim.files, state...)
Base.eltype(::Type{EPOCHSimulation}) = SDFFile
Base.length(sim::EPOCHSimulation) = length(sim.files)
Base.size(sim::EPOCHSimulation, args...) = size(sim.files, args...)

# Utils

Base.ndims(sim::EPOCHSimulation) = ndims(first(sim))
Base.haskey(sim::EPOCHSimulation, key) = haskey(sim.param, key)
Base.haskey(sim::EPOCHSimulation, block, key) = haskey(sim.param[block], key)
