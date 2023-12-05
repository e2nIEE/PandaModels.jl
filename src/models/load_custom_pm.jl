using PandaModels; const _PdM = PandaModels
import PowerModels; const _PM = PowerModels

json_path = "C:\\Users\\zliu\\.julia\\dev\\PandaModels\\test\\data\\test_custom.json"  # path of the json file
pm = _PdM.load_pm_from_json(json_path)
user_defined_params = pm["user_defined_params"]
print(debug)