struct EPOCHSimulation{F}
    dir::String
    files::F
end

function read_simulation(dir; field_cache_size=6, particle_cache_size=2, kwargs...)
    paths = filter(f->endswith(f, ".sdf"), readdir(dir))
    !issorted(paths) && sort!(paths)
    if isempty(paths)
        error("no .sdf files found in directory $dir")
        return nothing
    end

    # input_deck = joinpath(dir, "input.deck")
    # if isfile(input_deck)
    #     p = parse_input(input_deck)
    # else
    #     @warn "No input.deck found in $dir."
    #     p = missing
    # end

    # We assume that the particle_cache has the same dimensionality throughout
    # all the simulation, so we ca use the first file to get the dimensionality
    # and element type

    # N, T = get_data_description(joinpath(dir, first(paths)))
    # @debug "First file gave N = $N and T = $T"

    # field_cache = LRU{Tuple{String,AbstractBlockHeader},AbstractArray}(maxsize=field_cache_size, kwargs...)
    # particle_cache =  LRU{Tuple{String,AbstractBlockHeader},NTuple{N,Vector{T}}}(maxsize=particle_cache_size)

    files = SDFFile.(joinpath.((dir,), paths))

    EPOCHSimulation(dir, files)
end

# Indexing
Base.getindex(sim::EPOCHSimulation, i::Int) = sim.files[i]
Base.firstindex(sim::EPOCHSimulation) = firstindex(sim.files)
Base.lastindex(sim::EPOCHSimulation) = lastindex(sim.files)

# Iteration
Base.iterate(sim::EPOCHSimulation, state...) = iterate(sim.files, state...)
Base.iterate(r_sim::Iterators.Reverse{<:EPOCHSimulation}, state...) = iterate(Iterators.reverse(r_sim.itr.files), state...)
Base.eltype(::Type{EPOCHSimulation}) = SDFFile
Base.length(sim::EPOCHSimulation) = length(sim.files)
Base.size(sim::EPOCHSimulation, args...) = size(sim.files, args...)

# Utils

Base.ndims(sim::EPOCHSimulation) = ndims(first(sim))
Base.haskey(sim::EPOCHSimulation, key) = haskey(sim.param, key)
Base.haskey(sim::EPOCHSimulation, block, key) = haskey(sim.param[block], key)

# show
function Base.show(io::IO, ::MIME"text/plain", sim::EPOCHSimulation)
    first_file = first(sim)
    code_name = first_file.header.code_name
    n = length(sim)
    t₀ = si_round(get_time(first_file))
    t = si_round(get_time(last(sim)))
    # fc = Base.summarysize(sim.cache)
    # pc = Base.summarysize(sim.particle_cache)
    # c = Base.format_bytes(fc + pc)
    description = "$code_name simulation with $n files from " * t₀ * " to " * t * ".\n"
    # "Cache size: " * c
    print(io, description)
end
