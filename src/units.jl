# Credit to Stefanos Carlström (@jagot) https://github.com/PainterQubits/Unitful.jl/issues/240

function shift_unit(u::U, d, n) where {U<:Unitful.Unit}
    i₀ = floor(Int, d/n)
    d = 3i₀
    iszero(d) && return u,0
    for (i,tens) in enumerate(Unitful.tens(u) .+ (d:(-3*sign(d)):0))
        haskey(Unitful.prefixdict, tens) && return U(tens, u.power),i-1 + i₀
    end
    u,0
end

power_step(::Any) = 3

function shift_unit(u::Unitful.FreeUnits, d, idx)
    tu = typeof(u)
    us,ds,a = tu.parameters
    idx = length(us) == 1 && idx > 1 ? 1 : idx

    uu,i = shift_unit(us[idx], d, power_step(1u))

    Unitful.FreeUnits{(uu,us[setdiff(1:end,idx)]...), ds, a}(),i
end

function si_round(q::Quantity, idx=1)
    v,u = ustrip(q), unit(q)
    if !iszero(v)
        u,i = shift_unit(u, log10(abs(v)), idx)
        q = u(q/(one(q)^i))
    end
    @sprintf("%.3g %s", ustrip(q), unit(q))
end
