function compute_L(file, species)
    w, (x,y,z), px, py, pz = file["weight/"*species,
                                  "grid/"*species,
                                  "px/"*species,
                                  "py/"*species,
                                  "pz/"*species]

    r = SVector{3}.(x,y,z)
    p = VectorVariable(px, py, pz)

    L = w .* r .× p
end

compute_L(dir::Symbol, file, species) = compute_L(Val(dir), file, species)

function compute_L(::Val{:x}, file, species)
    w, r, py, pz = file["weight/"*species,
                        "grid/"*species,
                        "py/"*species,
                        "pz/"*species]

    y = r[2]
    z = r[3]
    Lx = @. w * (y * pz - z * py)
end
