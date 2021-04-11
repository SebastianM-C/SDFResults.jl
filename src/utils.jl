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

get_parameter(sim::EPOCHSimulation, p::Symbol) = getindex(sim.param, p)
get_parameter(sim::EPOCHSimulation, p::Symbol, c::Symbol) = getindex(get_parameter(sim, p), c)
