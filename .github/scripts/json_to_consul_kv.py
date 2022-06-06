import argparse
import json
import base64
import consul

def json_to_consul_kv(obj, path=''):
    try:
        result = []
        print(obj)
        for key, value in obj.items():
            new_path = path + '/' + key if path else key
            if isinstance(value, dict):
                result.extend(json_to_consul_kv(value, path=new_path))
            elif isinstance(value, list):
                new_path = new_path + '[0]'
                if isinstance(value[0], str):
                    result.append(new_path)
                else:
                    result.extend(json_to_consul_kv(value[0], path=new_path))
            else:
                result.append({"key":new_path,"value":base64.b64encode(bytes(str(value),'utf-8')).decode("ascii")})
                # result.append({"key":new_path,"value":str(value)})
        return result
    except Exception as e:
        print(str(e))
        if key: print(key)
        if value: print(value)

def consul_kv_import(consul_kv_json):
    consul_client = consul.Consul()
    for kv in consul_kv_json:
        try:
            consul_client.kv.put(kv['key'],kv['value'])
            print(f"Success! Data written to: {kv['key']}")
        except Exception as e:
            print(f"failed to import {kv['key']} :  {str(e)}")



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert json file to consul kv format')
    parser.add_argument("--file",dest='json_file',type=str)
    args = parser.parse_args()
    consul_kv=[]
    with open(args.json_file, 'r') as json_file:
        json_obj=json.load(json_file)
        consul_kv=json_to_consul_kv(json_obj,json_obj['app_name'])
        consul_kv_import(consul_kv)
    print(json.dumps(consul_kv))

