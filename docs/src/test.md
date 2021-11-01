# Test Guidelines

### Test PandaModels

Add the .json file of the pandapower net in data in test directory.
update the [runtests.jl](https://github.com/e2nIEE/PandaModels.jl/blob/develop/test/runtests.jl) file, and add tests, at least, for the .json file, user defined parameters and termination status.


### Test pandapower

All changes in [PandaModels](https://github.com/e2nIEE/PandaModels.jl) should be synced to [pandapower](https://github.com/e2nIEE/pandapower). To test the changes, first checkout to `develop` branch in [pandapower](https://github.com/e2nIEE/pandapower). Add the test for new function in pandapower, then in `Python`:

```python
import pandapower.test
pandapower.test.run_all_tests()
```

please check [here](https://github.com/e2nIEE/pandapower/blob/develop/tutorials/new_optimization_model_pandamodels.ipynb) to find out how call the new model in pandapower.
