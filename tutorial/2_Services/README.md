# Registering a Service

API gateways are an essential component of modern software architecture that provide a unified point of entry to a collection of microservices. One of the primary functions of a gateway is to route incoming requests to the appropriate sevice. To do this, the gateway must have knowledge of the available services, their endpoints, and the corresponding request and response types. In this tutorial, we will demonstrate how to register a service description on the ONTOCHAIN Gateway API.

### Content

[0 - Prerequisites](#0---prerequisites)  
[1 - Structure of a Service Description](#1---structure-of-a-service-description)  
[2 - Creating a Service Description](#2---creating-a-service-description)
[3 - Testing and Maintenance](#3---testing-and-maintenance)


## 0 - Prerequisites

To access the ONTOCHAIN Gateway API you need first your organization registered. Request such a registration through one of the following channels or reach out to your ONTOCHAIN contact for further information:

* Klevis Shkembi (University of Lubljana)  
  via ONTOCHAIN Slack

* Christoph Fabianek (OwnYourData)  
  via: christoph@ownyourdata.eu (please include "ONTOCHAIN GatewayAPI Registration" in the subject)

Your request should include information about the name of your organization and your affiliation to ONTOCHAIN (e.g., provide name and call # of your project).

As a response you will receive the organisation and user record created in the registration process.  
*Please note that the current setting is not meant for production use and especially security measures for onboarding need to be adapted in subsequent releases!*

**Example**  
Organisation record:
```json=
{
  "name":"OwnYourData",
  "jurisdiction":"Vienna, Austria",
  "organization-id":31
}
```

User record:
```json=
{
  "name": "admin",
  "user-id": 32,
  "oauth": {
    "client-id": "-hidden-",
    "client-secret":"-hidden-"
  }
}
```

With the registration process you receive the OAuth2 client credentials (`client-id` and `client-secret`) for the admin user of your organization. You can use the following code on the command line to generate an OAuth2 Bearer Token:

```bash=
export KEY="-insert client-id from your user-"
export SECRET="-insert client-secret from your user-"
export TOKEN=`curl -s -d grant_type=client_credentials -d client_id=$KEY -d client_secret=$SECRET -d scope=write -X POST https://babelfish.data-container.net/oauth/token | jq -r '.access_token'`
```

You can now use this token to access information on the Gateway API:

```bash=
curl -H "Authorization: Bearer $TOKEN" https://babelfish.data-container.net/organization/current
```
Response:    
```json=
{"organization-id":31,"name":"OwnYourData"}
```


## 1 - Structure of a Service Description

The Service Catalogue of the Gateway API comprises of all registered services. A service is a JSON object with the following attributes:  
* `interface`: describes the interface of the service (specifically API endpoints) and general aspects of the entity using the [Open API Specification v3](https://spec.openapis.org/oas/v3.1.0) (also known as Swagger documentation)  
* `data`: describes the expected data structure using [SOyA (Semantic Overlay Architecture)](https://ownyourdata.github.io/soya/) structures; if the data structure does not exist, this entry shall provide `null`; it is important to note that the content of this field is optional and services in ONTOCHAIN are not required to use SOYA- However, if those services decide to use SOyA, they benefit from the additional functionality in the integration helper  
* `governance`: describes the Usage Policy based on the structure from the [Data Privacy Vocabulary](https://w3c.github.io/dpv/dpv/) or similar - this information is used as input for Data Agreements

### Example of a complete Service Description

```json
{
  "interface": {
    "info": {
      "title": "General Linter",
      "description": "This sevice validates a JSON document against a SOyA structure."
    },
    "servers": [
      {
        "url": "https://linter.ownyourdata.eu"
      }
    ],
    "paths": {
      "/api/validate/{SOYA}": {
        "post": {
          "parameters": [
            {
              "name": "SOYA",
              "in": "path",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "content": {
              "application/json": {
                "schema": {}
              }
            }
          }
        }
      }
    }
  },
  "data": null,
  "governance": {
    "processing": [
      "analyse",
      "transform",
      "use"
    ],
    "purpose": [
      "validate"
    ],
    "retentionPeriod": "P0Y6M0DT0H0M0S"
  }
}
```

## 2 - Creating a Service Description

## 3 - Testing and Maintenance

## About  

<img align="right" src="https://raw.githubusercontent.com/OwnYourData/dc-babelfish/main/app/assets/images/logo-ngi-ontochain-positive.png" height="150">This project has received funding from the European Union’s Horizon 2020 research and innovation program through the [NGI ONTOCHAIN program](https://ontochain.ngi.eu/) under cascade funding agreement No 957338.


<br clear="both" />

## License

[MIT License 2023 - OwnYourData.eu](https://raw.githubusercontent.com/OwnYourData/dc-babelfish/main/LICENSE)
