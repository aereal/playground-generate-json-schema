Run as:

```sh
carton install
carton exec -- perl scripts/generate_schema.pl eg/*.json
```

Result:

```json
{
   "$schema" : "http://json-schema.org/draft-04/schema#",
   "description" : "TODO",
   "properties" : {
      "id" : {
         "example" : 1,
         "type" : "number"
      },
      "name" : {
         "example" : "yuno",
         "type" : "string"
      },
      "school" : {
         "properties" : {
            "location" : {
               "properties" : {
                  "lat" : {
                     "example" : 14,
                     "type" : "number"
                  },
                  "lon" : {
                     "example" : 15,
                     "type" : "number"
                  }
               },
               "type" : "object"
            },
            "name" : {
               "example" : "yamabuki",
               "type" : "null"
            }
         },
         "type" : "object"
      }
   },
   "title" : "TODO",
   "type" : "object"
}
```
