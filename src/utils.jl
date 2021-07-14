# Statistics
function Statistics.mean(f::Function, sim::EPOCHSimulation; cond=x->true)
    ThreadsX.map(sim.files) do file
        println("Loading $(file.name)")
        qunatity = f(file)
        z = zero(eltype(qunatity))
        (qunatity ./ length(qunatity)) |>
            Filter(cond) |>
            foldxt(+, simd=true, init=z)
    end
end

# FileTrees
# FileTrees._maketree(node::SDFFile) = File(nothing, basename(node.name), node)

pretty_summarysize(x) = Base.format_bytes(Base.summarysize(x))

get_parameter(sim::EPOCHSimulation, p::Symbol) = getindex(sim.param, p)
get_parameter(sim::EPOCHSimulation, p::Symbol, c::Symbol) = getindex(get_parameter(sim, p), c)

function domain_length(sdf, dir::Symbol)
    d_min = Symbol(string(dir)*"_min")
    d_max = Symbol(string(dir)*"_max")

    get_parameter(sdf, d_max) - get_parameter(sdf, d_min)
end

function domain_volume(sdf)
    nd = ndims(sdf)

    Δx = domain_length(sdf, :x)

    if nd == 1
        Δx
    elseif nd == 2
        Δy = domain_length(sdf, :y)
        Δx * Δy
    else
        Δy = domain_length(sdf, :y)
        Δz = domain_length(sdf, :z)
        Δx * Δy * Δz
    end
end

function cell_volume(sdf)
    nd = ndims(sdf)
    vol = domain_volume(sdf)
    nx = get_parameter(sdf, :nx)

    if nd == 1
        vol / nx
    elseif nd == 2
        ny = get_parameter(sdf, :ny)
        vol / (nx * ny)
    else
        ny = get_parameter(sdf, :ny)
        nz = get_parameter(sdf, :nz)
        vol / (nx * ny * nz)
    end
end

function cell_length(sdf, direction::Symbol)
    domain_length(sdf, direction)/get_parameter(sdf, Symbol("n"*"$direction"))
end

function timestep(sim)
    if haskey(sim, :dt_multiplier)
        C = get_parameter(sim, :dt_multiplier)
    else
        C = 0.95
    end

    n = ndims(sim)
    c = 2.99792458e8u"m/s" # https://github.com/Warwick-Plasma/epoch/blob/066d3dafd5582360c2e9136d2020cef404bb84f5/epoch1d/src/constants.F90#L147

    Δx = cell_length(sim, :x)

    if n == 1
        Δt = Δx / c
    elseif n == 2
        Δy = cell_length(sim, :y)
        Δt = inv(c * √(1/Δx^2 + 1/Δy^2))
    else
        Δy = cell_length(sim, :y)
        Δz = cell_length(sim, :z)

        Δt = inv(c * √(1/Δx^2 + 1/Δy^2 + 1/Δz^2))
    end

    return C * Δt
end
