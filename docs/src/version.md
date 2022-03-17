# Update Version

After implementing, testing, and providing the tutorial documentation for the new model, to call the model from [pandapower](https://pandapower.readthedocs.io/en/latest/index.html), you might register your new features to the global version of the PandaModels. The reason is that when the (non-developer) pandapower users run optimization models, indeed, they call the models from the registered version of PandaModels.

In this case, you need to change the version in `Project.toml` then push your changes to the develop branch, otherwise, the documentation actions will not pass. After all required actions pass, make a pull request to the main branch and create a new issue, and comment `@JuliaRegistrator register`. For more information please check [Julia Registrator](https://github.com/JuliaRegistries/Registrator.jl).

!!! warning "pandapower Development"
    **only** after updating the PandaModels version, you are able to create a **pull request in pandapower** otherwise the tests related to your new optimization model will be failed.
