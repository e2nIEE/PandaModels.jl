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
        "Models" => ["Redispatch" => "redispatch.md"],
        "Developer" => [
            "Develop Mode" => "develop.md",
            "Optimization Model Guidlines" => "model.md",
            "Add Test" => "test.md",
            "Register New Tag" => "version.md",
        ],
    ],
    doctest = true,
    linkcheck = true,
    # Some external hosts block/rate-limit the CI link checker (GitHub returns 429 for the tutorial
    # links, and a few external sites answer 403/404 to the bot user agent even though the pages
    # exist). Ignore those so the link check does not fail on network-side responses we do not
    # control; internal cross references are still checked.
    linkcheck_ignore = [
        r"https://github\.com/e2nIEE/pandapower/blob/.*",
        r"https://www\.computerhope\.com/.*",
        r"https://www\.uni-kassel\.de/.*",
        r"https://www\.gurobi\.com/.*",
    ],
)

deploydocs(
    repo = "github.com/e2nIEE/PandaModels.jl.git",
    push_preview = true,
    devbranch = "main",
    # devurl = "dev",
    # versions = ["stable" => "v^", "v#.#", devurl => devurl]
)
