import requests
import sys
import json

# determine where to send requests
elasticsearchApiRoot = sys.argv[1] # for example: http://localhost:9200/"
componentTemplateEndpoint = elasticsearchApiRoot + "_component_template/logs-settings"

# get current settings as json
response = requests.get(componentTemplateEndpoint)
componentTemplateConf = json.loads(response.text)

# set new values
componentTemplateConf["component_templates"][0]["component_template"]["version"] = 2 # overwrites existing value
componentTemplateConf["component_templates"][0]["component_template"]["template"]["settings"]["index"]["number_of_replicas"] = 0 # adds new field

# send update request
newComponentTemplate = componentTemplateConf["component_templates"][0]["component_template"]
response = requests.post(componentTemplateEndpoint, json=newComponentTemplate)

# throw error for anything except 200 (OK)
if response.status_code == 200:
    sys.exit(0)
else:
    sys.exit(response.status_code)
