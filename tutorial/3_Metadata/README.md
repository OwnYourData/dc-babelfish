# Metadata Management

*last update: 29 March 2023*  

Metadata management is a critical aspect of data governance and analysis, which involves the organization, standardization, and maintenance of metadata. Metadata refers to the data that describes other data, such as data elements, data structures, data types, and data relationships. In today's data-driven world, metadata management is essential to ensure the accuracy, consistency, and completeness of data, as well as to facilitate data integration, data discovery, and data reuse. In this tutorial, we will provide an overview of metadata management using the NGI ONTOCHAIN Gateway API. Refer to the [Tutorial-Overview](https://github.com/OwnYourData/dc-babelfish/tree/main/tutorial) for other aspects of the Gateway API.

### Content

[0 - Prerequisites](#0---prerequisites)  
[1 - Default Metadata Attributes](#1---default-metadata-attributes)  
[2 - Retrieving Metadata Information](#2---retrieving-metadata-information)  
[3 - Reserved Names for Metadata](#3---reserved-names-for-metadata)  
[4 - Decentralised Identifiers, Verifiable Credentials and Verifiable Presentations for Objects](#4---decentralised-identifiers-verifiable-credentials-and-verifiable-presentations-for-objects)

&nbsp;

## 0 - Prerequisites

To walk through this tutorial make sure to have an existing account on the Gateway API and that you are able to create a token for authorization - [check Service Tutorial for details](https://github.com/OwnYourData/dc-babelfish/tree/main/tutorial/2_Service#0---prerequisites)

Throughout this tutorial we will use the following preconfigured entities if not specified otherwise:
* Organisation: *Demo Organisation* with ID 77
* User: *Demo User* with ID 89
  OAuth2 credentials for this user are:
  * `client-id`: "-6H7FHYo4aX5-dYMVF82x2_rzO1cXIB5URc24dPwMls"
  * `client-secret`: "cnhNgI77IMVeyenhZnPylcD_XKO72piWzzT68psVKJA"
  * <details><summary>code sample to retrieve <code>TOKEN</code> on the command line</summary>  

    ```bash=
    export KEY="-6H7FHYo4aX5-dYMVF82x2_rzO1cXIB5URc24dPwMls"
    export SECRET="cnhNgI77IMVeyenhZnPylcD_XKO72piWzzT68psVKJA"
    export TOKEN=`curl -s -d grant_type=client_credentials -d client_id=$KEY -d client_secret=$SECRET -d scope=write -X POST https://babelfish.data-container.net/oauth/token | jq -r '.access_token'`
    ```
    </details>
* Collection: *Demo Collection* with ID 99
* Object: *Demo Object* with ID 100

[back to top](#)


## 1 - Default Metadata Attributes

The following meta attributes exist for each object:  
* `id` - unique ID provided by the respective storage provider (is constant accross updates)
* `dri` - content-based address (hash-value) of the object (changes with every update)
* `created_at` - timestamp when object was initially created
* `updated_at` - timestamp of last update

*note: these attributes cannot be set / changed by the user and are maintained by the system*

[back to top](#)


## 2 - Writing & Retrieving Metadata Information

To **create an object** and provide metadata the following structure should be used (i.e., use `meta`):
```json
{
  "key": "value",
  "meta": {
      "my": "metadata"
  }
}
```

<details><summary>Example for creating an object with metadata</summary>

```bash=
echo '{"key":"value","collection-id":99,"meta":{"my":"metadata"}}' | \
   curl -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d @- \
        -X POST https://babelfish.data-container.net/object
```

</details>


**Retrieve meta data** information with `GET /object/{ID}/meta`.  

Example:  
`curl -H "Authorization: Bearer $TOKEN" https://babelfish.data-container.net/object/100/meta`  
Response:
```json
{
  "type": "object",
  "organization-id": "77",
  "dri": "zQmcnSfLY1AJqMZWtEEWBCo1i56xkPHz4f2HntsbmBXZCHW",
  "created-at": "2023-03-28T23:09:22.405Z",
  "updated-at": "2023-03-28T23:09:22.405Z",
  "object-id": 100
}
```

Further notes:  

* use `data` and `meta` separately to write anything into the actual object (even *meta*)  
  Example:   
  ```json
  {
    "data": {
        "key": "value",
    },
    "meta": {
        "my": "metadata"
    }
  }
  ```

* if you update an object and you don't provide `meta` the meta information is not changed; if you provide `meta` it is overwritten, i.e., you need to provide also any existing meta information

[back to top](#)


## 3 - Reserved Names for Metadata

the following meta attributes have a special meaning / are recognized in a specific way by the Gateway API:  
* `schema`
* `provenance` - if provided must be a JSON-LD document according to the W3C Prov-O specification  

  <details><summary>Provenance Example</summary>
        
  Example: 
  ```json-ld=
  {
    "@context": {
      "@version": 1.1,
      "xsd": "http://www.w3.org/2001/XMLSchema#",
      "rsd": "http://www.w3.org/2000/01/rdf-schema",
      "prov": "http://www.w3.org/ns/prov#",
      "foaf": "http://xmlns.com/foaf/0.1/",
      "semcon": "http://w3id.org/semcon/ns/ontology",
      "semcon_res": "http://w3id.org/semcon/resource/"
    },
    "@graph": [
      {
        "@id": "semcon_res:container_41f80b87-9b8d", <- how to use DID of Storage Service?
        "@type": "prov:softwareAgent",
        "semcon:containerInstanceId": "41f80b87-9b8d-43d6-ba5e-aed6b837dbd6", <- just identifier of DID
        "rsd:comment": "Service Description of Storage Service",
        "rsd:label": "Titel of Storage Service",
        "prov:actedOnBehalfOf": {
          "@id": "semcon_res:operator_a130a813440e" <- reference operator below
        }
      },
      {
        "@id": "http://w3id.org/semcon/resource/data_e2407dfa3192_41f80b87",
        "@type": "prov:Entity",
        "semcon:dataHash": "e2407dfa3192b05f2add4ee2aa1b127f2f24916370298946b159298770ddc3f6",
        "label": "data set from 2019-05-28T16:10:33Z",
        "prov:generatedAtTime": {
          "@type": "xsd:dateTime",
          "@value": "2019-05-28T16:10:33Z"
        },
        "prov:wasAttributedTo": {
          "@id": "semcon_res:container_41f80b87-9b8d"
        }
      },
      {
        "@id": "semcon_res:input_5b697319f458",
        "@type": "prov:Activity",
        "semcon:inputHash": "5b697319f458166ac6d66ab5a151164ba357de42ce751d07ee9b17a08f9c838a",
        "label": "input data from 2019-05-28T15:00:39Z",
        "http://www.w3.org/ns/prov#endedAtTime": {
          "@type": "xsd:dateTime",
          "@value": "2019-05-28T15:00:39Z"
        },
        "prov:generated": {
          "@id": "semcon_res:data_e2407dfa3192_41f80b87"
        },
        "http://www.w3.org/ns/prov#startedAtTime": {
          "@type": "xsd:dateTime",
          "@value": "2019-05-28T15:00:37Z"
        }
      },
      {
        "@id": "semcon_res:operator_a130a813440e", <- how to use DID of Operator?
        "@type": [
          "foaf:Person",
          "prov:Person"
        ],
        "semcon:operatorHash": "a130a813440e6fc01bd174e333ac2ade366372cbd09f6d460ac96c5d1eccf641", <- just identifier of DID
        "foaf:mbox": {"@id": "mailto:christoph@ownyourdata.eu"}, <- necessary? available through DID
        "foaf:name": "Christoph Fabianek"
      }
    ]
  }
  ```
  
  </details>

[back to top](#)


## 4 - Decentralised Identifiers, Verifiable Credentials and Verifiable Presentations for Objects

* this information is not stored as metadata but uses metadata to reference it
* example to create DID for object using did:oyd Method and Uniregistrar
* example to create VC for object using `oydid` command line tool

[back to top](#)


&nbsp;

## About  

<img align="right" src="https://raw.githubusercontent.com/OwnYourData/dc-babelfish/main/app/assets/images/logo-ngi-ontochain-positive.png" height="150">This project has received funding from the European Union’s Horizon 2020 research and innovation program through the [NGI ONTOCHAIN program](https://ontochain.ngi.eu/) under cascade funding agreement No 957338.


<br clear="both" />

## License

[MIT License 2023 - OwnYourData.eu](https://raw.githubusercontent.com/OwnYourData/dc-babelfish/main/LICENSE)
