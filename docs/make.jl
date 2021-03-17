using PandaModels
using Documenter

makedocs(;
    modules=[PandaModels],
    authors="e2nIEE",
    repo="https://github.com/e2nIEE/PandaModels.jl/blob/{commit}{path}#L{line}",
    sitename="PandaModels.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://e2nIEE.github.io/PandaModels.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/e2nIEE/PandaModels.jl",
)
