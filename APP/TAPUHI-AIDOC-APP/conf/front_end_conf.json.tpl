{
  "app_name" : "tapuhi-app-1",
  "description": "{{ key "tapuhi-app-1/description" | base64Decode }}",
  "conf": {
    "active": {{ key "tapuhi-app-1/conf/active"  | base64Decode}},
    "image": "{{ key "tapuhi-app-1/conf/image"  | base64Decode}}",
    "url" : "{{ key "tapuhi-app-1/conf/url"  | base64Decode}}",
    "files" : {
      "file_1" : {
        "id": {{ key "tapuhi-app-1/conf/files/file_1/id" | base64Decode }},
        "source_url": "{{ key "tapuhi-app-1/conf/files/file_1/source_url"  | base64Decode}}"
      },
      "file_2" : {
        "id": {{ key "tapuhi-app-1/conf/files/file_2/id" | base64Decode }},
        "source_url": "{{ key "tapuhi-app-1/conf/files/file_2/source_url"  | base64Decode}}"
      }
    }
  }
}

