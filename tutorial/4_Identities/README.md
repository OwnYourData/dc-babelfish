# Identity Management with `did:oyd`

*last update: 29 April 2023*  

Welcome to our comprehensive tutorial on utilizing Decentralized Identifiers (DIDs) to empower your digital identity management! In this hands-on guide, we will delve into the core concepts and advantages of the `did:oyd` method, and demonstrate step-by-step how to create, authenticate, and manage your own decentralized identifiers. By the end of this tutorial, you will have gained valuable insights into the world of decentralized identity management and possess the skills to harness its potential for your projects, applications, and personal use. Refer to the [Tutorial-Overview](https://github.com/OwnYourData/dc-babelfish/tree/main/tutorial) for other aspects of the NGI ONTOCHAIN Gateway API.

### Content

[0 - Prerequisites](#0---prerequisites)  
[1 - Creating a DID](#1---creating-a-did)  
[2 - Resolving a DID](#2---resolving-a-did)  
[3 - DID Lifecycle](#3---did-lifecycle)  
[4 - Delegation](#4---delegation)  
[5 - Verifiable Credentials & Verifiable Presentations](#5---verifiable-credentials--verifiable-presentations)  

&nbsp;

## 0 - Prerequisites

### On the Command Line  
To execute commands in the steps below make sure to have the following tools installed:    
* `oydid`: download and installation instructions [available here](https://github.com/OwnYourData/oydid/tree/main/cli)    
* `jq`: download and installation instructions [available here](https://stedolan.github.io/jq/download/)    

Alternatively, you can use a ready-to-use Docker image with all tools pre-installed:    
[https://hub.docker.com/r/oydeu/oydid-cli](https://hub.docker.com/r/oydeu/oydid-cli) 

> Use the following command to start the image:    
> 
> ```console
> docker run -it --rm -v ~/.oydid:/home/user oydeu/oydid-cli
> ```
> 
> *Note:* since it makes sense to keep data beyond a Docker session, a directory is mounted in the container to persist files; create this local directory with the command `mkdir ~/.oydid`

### Using a Web Service
To manage DIDs beyond the command line, i.e., when you want to integrate `did:oyd` into your application, it is also possible to access all functions via an API. As the de-facto standard the DIF [Uniresolver](https://resolver.identity.foundation/) and [Uniregistrar](https://uniregistrar.io/) have specified the relevant endpoints and `did:oyd` is fully compliant (see also the relevant [Swagger documentation here](https://oydid.ownyourdata.eu/api-docs/index.html)).

### OYDID Repository
For `did:oyd` the DID document and associated logs are stored in a repository. In this tutorial we use either the default OYDID repo (https://oydid.ownyourdata.eu) or the NGI ONTOCHAIN Gateway API (https://babelfish.data-container.net). Read more about [deployment options for OYDID repositories here](https://github.com/OwnYourData/oydid/tree/main/tutorial#deployment).

[back to top](#)

## 1 - Creating a DID

The most simple DID without any services can be created with the following command:

```bash=
echo '' | oydid create
```

Here you specify an empty input `echo ''`, use the default repository for publishing (https://oydid.ownyourdata.eu), and cryptographic material is stored in your local directory (`ls zQm*`). Similarily you can create a simple DID with the following API call:

```bash=
echo '' | curl -H "Content-Type: application/json" -d @- -X POST https://oydid.ownyourdata.eu/1.0/create
```

*Note:* in the above example no private keys were included in the input and therefore random keys were generated and returned in the response

A number of options (either on the command line or via the JSON input of the API call) are available to specify specific aspects of the DID creation process. Among the most frequent options on the command line are:  
* `-l`: choose a repository
* `--doc-pwd` and `-rev-pwd`: use a passphrase as input for the document and revocation key
* `-z`: us a specific timestamp (instead of the current time) for DID creation to have a reproducible output

Either run `oydid --help` to see all available options on the command line or find a description for the [inputs for API calls here](https://github.com/OwnYourData/oydid/tree/main/uni-registrar-driver-did-oyd#driver-input-options).

In the next sections we are using a DID created with the following command:

* on the command line:  
  ```bash=
  echo '{"service":{"serviceEndpoint":"https://babelfish.data-container.net/list"}}' | \
  oydid create --doc-pwd pwd1 --rev-pwd pwd2 -z 1 -s
  ```

* or via API:
  ```bash=
  echo '{
    "options": {
      "ts": 1
    },
    "secret": {
      "doc_pwd": "pwd1",
      "rev_pwd": "pwd2"
    },
    "didDocument": {
       "service": {
         "serviceEndpoint":"https://babelfish.data-container.net/list"
      }
    }
  }' | curl -H "Content-Type: application/json" -d @- -X POST https://oydid.ownyourdata.eu/1.0/create
  ```

Both commands create the DID: [`did:oyd:zQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud`](https://resolver.identity.foundation/#did:oyd:zQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud)

[back to top](#)

## 2 - Resolving a DID

Resolving a DID can be performed on the command line with `oydid read`:

```bash
oydid read did:oyd:zQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud
```

The response of this command is a JSON object with the internal representation of the DID Document:  
* `doc`: the payload
* `key`: public keys
* `log`: reference to the associated log

```json
{
  "doc": {
    "service": {
      "serviceEndpoint": "https://babelfish.data-container.net/list"
    }
  },
  "key": "z6MuvWooepYBxXLdYggPjxfEZCW3DqDhapLCnYDxnQjkoShA:z6Mv2CANJwu6QJfowhyqeFp5VoZUL4RyNZDwRcpgNrLVc5dh",
  "log": "zQmTjbVKvYJnDzkyEU7xd5uhiGfGcAi9hhckKScAacAfm8o"
}
```

To show the DID in the W3C-conform representation use the `--w3c-did` option:
```console
oydid read --w3c-did did:oyd:zQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud
```

and retrieve as output a JSON-LD document:  
```json
{
  "@context": [
    "https://www.w3.org/ns/did/v1",
    "https://w3id.org/security/suites/ed25519-2020/v1"
  ],
  "id": "did:oyd:zQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud",
  "verificationMethod": [
    {
      "id": "did:oyd:zQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud#doc-key",
      "type": "Ed25519VerificationKey2020",
      "controller": "did:oyd:zQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud",
      "publicKeyMultibase": "z6MuvWooepYBxXLdYggPjxfEZCW3DqDhapLCnYDxnQjkoShA"
    },
    {
      "id": "did:oyd:zQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud#rev-key",
      "type": "Ed25519VerificationKey2020",
      "controller": "did:oyd:zQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud",
      "publicKeyMultibase": "z6Mv2CANJwu6QJfowhyqeFp5VoZUL4RyNZDwRcpgNrLVc5dh"
    }
  ],
  "service": [
    {
      "id": "did:oyd:zQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud#payload",
      "type": "Custom",
      "serviceEndpoint": "https://babelfish.data-container.net/list"
    }
  ]
}
```

Using the API endpoint `GET /1.0/identifiers` always returns the W3C format:

```bash
curl https://oydid.ownyourdata.eu/1.0/identifiers/did%3Aoyd%3AzQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud
```

And you can always use the [Uniresolver web service](https://uniresolver.io) to display the DID document in your web browser:  
https://resolver.identity.foundation/#did:oyd:zQmZ12f8p68XN4tRsWQY8evKBwNdEiCuWzgSm6ZACifebud

[back to top](#)

## 3 - DID Lifecycle

* Update
* Revoke

[back to top](#)

## 4 - Delegation

* delegating doc-key
* delegating rev-key

[back to top](#)

## 5 - Verifiable Credentials & Verifiable Presentations

* creating a Verifiable Credential
* creating only the proof for a VC
* creating a Verifiable Presentation

[back to top](#)


&nbsp;

## About  

<img align="right" src="https://raw.githubusercontent.com/OwnYourData/dc-babelfish/main/app/assets/images/logo-ngi-ontochain-positive.png" height="150">This project has received funding from the European Union’s Horizon 2020 research and innovation program through the [NGI ONTOCHAIN program](https://ontochain.ngi.eu/) under cascade funding agreement No 957338.


<br clear="both" />

## License

[MIT License 2023 - OwnYourData.eu](https://raw.githubusercontent.com/OwnYourData/dc-babelfish/main/LICENSE)
