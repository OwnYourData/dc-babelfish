# Tranformation between Data Models

*last update: 2 May 2023*  

This tutorial introduces the use of the **S**emantic **O**verla**y** **A**rchitecture (SOyA) with a special focus on transformation of datasets between data models. Refer to the [Tutorial-Overview](https://github.com/OwnYourData/dc-babelfish/tree/main/tutorial) for other aspects of the ONTOCHAIN Gateway API.

### Content

[0 - Prerequisites](#0---prerequisites)  
[1 - Describing Data Models in YAML](#1-describing-data-models-in-yaml)  
[2 - Publishing Structures](#2-publishing-structures)  
[3 - Working with Instances](#3-working-with-instances)  
[4 - Validating Datasets against Constraints](#4-validating-datasets-against-constraints)  
[5 - Transforming Datasets](#5-transforming-datasets)  

&nbsp;

## 0 - Prerequisites

To execute commands in the steps below make sure to have the following tools installed:    
* `soya`: download and installation instructions [available here](https://github.com/OwnYourData/soya/tree/main/cli)    
    TL;DR: just run `npm i -g soya-cli@latest` or update with `npm update -g soya-cli`
* `jq`: download and installation instructions [available here](https://stedolan.github.io/jq/download/)    

Alternatively, you can use a ready-to-use Docker image with all tools pre-installed:    
[https://hub.docker.com/r/oydeu/soya-cli](https://hub.docker.com/r/oydeu/soya-cli) 

> Use the following command to start the image:    
> 
> ```console
> docker run -it --rm -v ~/.soya:/home/user oydeu/soya-cli
> ```
> 
> *Note:* since it makes sense to keep data beyond a Docker session, a directory is mounted in the container to persist files; create this local directory with the command `mkdir ~/.soya`

[back to top ↑](#top)


## 1. Describing Data Models in YAML

This section covers the use of
* [Bases](#meta-and-bases-section): describing the attributes and associated types of a data model
* [Overlays](#overlays-section): providing additional information beyond the data structure
within a SOyA structure (a YAML-based data model for describing graph data that is RDF-compatible).

### `meta` and `bases` Section

Start with creating a very simple data model for an organisation that only has 2 attributes `name` and `founded`:

Example: [`org_simple.yml`](examples/org_simple.yml)
```yaml
meta:
  name: Organisation

content:
  bases:
    - name: Organisation 
      attributes:
        name: String
        founded: Date
```

The 2 main sections in the YML file are `meta` (providing the name) and `content`. In this simple example the `content` includes only 1 `base` (or data model), namely the class `Organisation` with the attributes `name` and `founded`.

Use the command `soya init` to create a JSON-LD document from the yml input file:
```bash
cat org_simple.yml | soya init
```
<details><summary>Output</summary>

Use the following command to generate the output:    
```bash
curl -s https://playground.data-container.net/org_simple | jq -r .yml | soya init
```

```json-ld
{
  "@context": {
    "@version": 1.1,
    "@import": "https://ns.ownyourdata.eu/ns/soya-context.json",
    "@base": "https://soya.ownyourdata.eu/Organisation/",
    "xsd": "http://www.w3.org/2001/XMLSchema#"
  },
  "@graph": [
    {
      "@id": "Organisation",
      "@type": "owl:Class",
      "subClassOf": "soya:Base"
    },
    {
      "@id": "name",
      "@type": "owl:DatatypeProperty",
      "domain": "Organisation",
      "range": "xsd:string"
    },
    {
      "@id": "founded",
      "@type": "owl:DatatypeProperty",
      "domain": "Organisation",
      "range": "xsd:date"
    }
  ]
}
```

</details>

#### Attributes

Attributes are single fields in a base with a name and an associated type. The associated type can be one of the predefined values (`Boolean`, `Integer`, `Float`, `Decimal`, `String`, `Date`, `Time`, `DateTime`) or reference another base. The following example provides the description of an employee ([`employee.yml`](examples/employee.yml)) demonstrating the use of various attributes.

```yaml
meta:
  name: Employee

content:
  bases:
    - name: Employee
      attributes:
        name: String
        management: Boolean
        salary: Float
        employer: Organisation
    - name: Organisation 
      attributes:
        name: String
        founded: Date
        staff_count: Integer
```

<details><summary>Try it out!</summary>

Use the following command to generate the output:    
```bash
curl -s https://playground.data-container.net/employee | jq -r .yml | soya init
```

```json-ld
{
  "@context": {
    "@version": 1.1,
    "@import": "https://ns.ownyourdata.eu/ns/soya-context.json",
    "@base": "https://soya.ownyourdata.eu/Employee/",
    "xsd": "http://www.w3.org/2001/XMLSchema#"
  },
  "@graph": [
    {
      "@id": "Employee",
      "@type": "owl:Class",
      "subClassOf": "soya:Base"
    },
    {
      "@id": "name",
      "@type": "owl:DatatypeProperty",
      "domain": "Employee",
      "range": "xsd:string"
    },
    {
      "@id": "management",
      "@type": "owl:DatatypeProperty",
      "domain": "Employee",
      "range": "xsd:boolean"
    },
    {
      "@id": "salary",
      "@type": "owl:DatatypeProperty",
      "domain": "Employee",
      "range": "xsd:float"
    },
    {
      "@id": "employer",
      "@type": "owl:ObjectProperty",
      "domain": "Employee",
      "range": "Organisation"
    },
    {
      "@id": "Organisation",
      "@type": "owl:Class",
      "subClassOf": "soya:Base"
    },
    {
      "@id": "name",
      "@type": "owl:DatatypeProperty",
      "domain": "Organisation",
      "range": "xsd:string"
    },
    {
      "@id": "founded",
      "@type": "owl:DatatypeProperty",
      "domain": "Organisation",
      "range": "xsd:date"
    },
    {
      "@id": "staff_count",
      "@type": "owl:DatatypeProperty",
      "domain": "Organisation",
      "range": "xsd:integer"
    }
  ]
}
```

</details>


### `overlays` Section

Overlays provide addtional information for a defined base. This information can either be directly included in a structure together with a base or is provided independently and linked to the relevant base. The following types of overlays are pre-defined in the default context (https://ns.ownyourdata.eu/soya/soya-context.json): Annotation, Format, Encoding, Form, Classification, Alignment, Validation, and Transformation. It is possible to create additional overlay types by using another context.

*Hint:* use the command `soya template <type>` to show an example for each of the overlay types on the command line (e.g., `soya template annotation`)

[back to top ↑](#top)


## 2. Publishing Structures
After creating a standardized definition of a data model it can be uploaded or "pushed" to an online repository, where it can be accessed and shared by other developers and team members. To run your own instance of a SOyA repository use the [sources on Github](https://github.com/OwnYourData/soya) or the [`oydeu/soya-base` image on Dockerhub](https://hub.docker.com/r/oydeu/soya-base). For the examples in this tutorial we will use the public SOyA repository hosted at https://soya.ownyourdata.eu.

### Upload to Repository (`soya init-push`)
As already shown in section 1 the command `soya init` transforms a YAML file into JSON-LD and thus creates a standard-conform RDF representation of the data model. To publish the JSON-LD the command `soya push` reads a valid SOyA structure from STDIN and stores it in a repository.

*Example:* continuing the [example from above](examples/org_simple.yml) we can chain the following commands on the command line  
```bash
cat org_simple.yml | soya init | soya push
```

And since the process of converting and uploading a SOyA structure is a very common task there is also a short-cut as `soya init-push` available:
```bash
curl -s https://playground.data-container.net/employee | jq -r .yml | soya init-push
```

*Note:* if publishing the SOyA strcucture was successful the name under which it is available is shown (otherwise the specific error is displayed)
```
$ cat org_simple.yml | soya init-push
Organisation
```

### Download from Repository (`soya pull`)


[back to top ↑](#top)


## 3. Working with Instances

### Transform flat-JSON Records into JSON-LD (`soya acquire`)

### Editing Records in HTML Forms (`soya form`)


[back to top ↑](#top)


## 4. Validating Datasets against Constraints

### Validation Overlay

### Checking Conformance (`soya validate`)

[back to top ↑](#top)


## 5. Transforming Datasets

### Transformation Overlay

### Transfrom Instances between Structures (`soya transform`)

### Alignment Overlays and Mapping (`soya map`)


[back to top](#)


&nbsp;

## About  

<img align="right" src="https://raw.githubusercontent.com/OwnYourData/dc-babelfish/main/app/assets/images/logo-ngi-ontochain-positive.png" height="150">This project has received funding from the European Union’s Horizon 2020 research and innovation program through the [NGI ONTOCHAIN program](https://ontochain.ngi.eu/) under cascade funding agreement No 957338.


<br clear="both" />

## License

[MIT License 2023 - OwnYourData.eu](https://raw.githubusercontent.com/OwnYourData/dc-babelfish/main/LICENSE)
