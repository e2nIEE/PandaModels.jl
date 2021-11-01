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
        "Tutorials" => [
            # "Power Flow" => "pf.md",
            "Optimal Power Flow" => "opf.md",
            "Optimal Transmission Switching" => "ots.md",
            # "Timeseries and Multinetwork" => "ts_mn.md",
            "Optimal MultiNetwork Storage" => "omns.md",
            "Transmission Network Expansion Planning" => "tnep.md",
            "Optimal Voltage Deviation" => "vd.md",
            # "Radial Distribution Network" => "rds.md",
        ],
        "Developer" => [
            "Develop Mode" => "develop.md",
            # "Model Guidlines" => "model.md",
            # "Call Model in pandapower" => "modelpp.md",
            "Add Test" => "test.md",
        ],
    ],
    doctest = true,
    linkcheck = true,
)

deploydocs(
    repo = "github.com/e2nIEE/PandaModels.jl.git",
    push_preview = true,
    devbranch = "main",
    devurl = "develop",
    versions = ["stable" => "v^", "v#.#", devurl => devurl]
)
