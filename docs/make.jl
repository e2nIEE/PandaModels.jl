using Documenter, PandaModels

makedocs(
    modules = [PandaModels],
    authors = "e2nIEE",
    sitename = "PandaModels",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical="https://e2nIEE.github.io/PandaModels.jl/stable/",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "Manual" => ["Getting Started" => "quickguide.md"],
        "Tutorials" => ["Optimazion Problems"  => "pptutorial.md"],
        "Developer" => [
            "Develop Mode" => "develop.md",
            "Optimization Model Guidlines" => "model.md",
            "Add Test" => "test.md",
            "Register New Tag" => "version.md",
        ],
    ],
    doctest = true,
    linkcheck = true,
)

deploydocs(
    repo = "github.com/e2nIEE/PandaModels.jl.git",
    push_preview = true,
    devbranch = "main",
    # devurl = "dev",
    # versions = ["stable" => "v^", "v#.#", devurl => devurl]
)
