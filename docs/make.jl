using SDFResults
using Documenter

makedocs(;
    modules=[SDFResults],
    authors="Sebastian Micluța-Câmpeanu <m.c.sebastian95@gmail.com> and contributors",
    repo="https://github.com/SebastianM-C/SDFResults.jl/blob/{commit}{path}#L{line}",
    sitename="SDFResults.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://SebastianM-C.github.io/SDFResults.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/SebastianM-C/SDFResults.jl",
)
