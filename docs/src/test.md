# Test Guidelines

### Test PandaModels

Add pandapower net as test case and its path to in [create_test_json.py](https://github.com/e2nIEE/PandaModels.jl/blob/develop/test/create_test_json.py).
update the [runtests.jl](https://github.com/e2nIEE/PandaModels.jl/blob/develop/test/runtests.jl) file, and run test in `Julia`.

### Test pandapower

All changes in [PandaModels](https://github.com/e2nIEE/PandaModels.jl) should be synced to [pandapower](https://github.com/e2nIEE/pandapower). To test the changes, first checkout to `julia_pkg` branch in [pandapower](https://github.com/e2nIEE/pandapower). Add the test case to [test_powermodels.py](https://github.com/e2nIEE/pandapower/blob/julia_pkg/pandapower/test/opf/test_powermodels.py) , then run pandapower test in `Python` :

```python
import pandapower.test
pandapower.test.run_all_tests()
```
