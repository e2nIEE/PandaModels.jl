using Documenter, PandaModels

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
        "Manual" => [
        "Getting Started" => "quickguide.md",
        ],
        "Tutorials" => [
        # "Power Flow" => "pm_pf.md",
        "Optimal Power Flow" => "pm_opf.md",
        "Optimal Transmission Switching" => "pm_ots.md",
        # "Timeseries and Multinetwork" => "pm_ts_mn.md",
        "Optimal MultiNetwork Storage" => "pm_omns.md",
        "Transmission Network Expansion Planning" => "pm_tnep.md",
        # "Optimal Voltage Deviation" => "pm_vd.md",
        # "Radial Distribution Network" => "pm_rds.md",
        ],
        "Developer" => [
                "Develop Mode" => "develop.md",
                # "Model Guidlines" => "newmodel.md",
                # "Call Model in pandapower" => "newmodelpp.md",
                "Add Test" => "test.md",
        ],
    ],

    # repo = "https://github.com/e2nIEE/PandaModels.jl/blob/{commit}{path}#L{line}",
    # sitename = "PandaModels.jl",
    doctest = true,
    linkcheck = true,
    # format = Documenter.HTML(
    #     # See https://github.com/JuliaDocs/Documenter.jl/issues/868
    #     prettyurls = get(ENV, "CI", nothing) == "true",
    #     analytics = "UA-178297470-1",
    #     collapselevel = 1,
    #     )
)

deploydocs(;
    repo="github.com/e2nIEE/PandaModels.jl",
    # push_preview = true
)
