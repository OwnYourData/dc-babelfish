# Tranformation between Data Models

*last update: 2 May 2023*  

This tutorial introduces the use of the **S**emantic **O**verla**y** **A**rchitecture (SOyA) with a special focus on transformation of datasets between data models. Refer to the [Tutorial-Overview](https://github.com/OwnYourData/dc-babelfish/tree/main/tutorial) for other aspects of the ONTOCHAIN Gateway API.

### Content

[0 - Prerequisites](#0---prerequisites)  
[1 - Describing Data Models in YAML](#1-describing-data-models-in-yaml)

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

Overlays provide addtional information for a defined base. This information can either be directly included in a structure together with a base or is provided independently and linked to the relevant base. The following types of overlays are pre-defined in the default context (https://ns.ownyourdata.eu/soya/soya-context.json):
* [Annotation](#annotation)
* [Format](#format)
* [Encoding](#encoding)
* [Form](#form)
* [Classification](#classification)
* [Alignment](#alignment)
* [Validation](#validation)
* [Transformation](#transformation)

It is possible to create additional overlay types by using another context.

#### Annotation

The *Annoation* overlay provides human-readable text and translations in different languages for base names, labels, and descriptions. In YAML it has the following format:

```yaml
meta:
  name: SampleAnnotation

content:
  overlays: 
    - type: OverlayAnnotation
      base: NameOfBase
      name: SampleAnnotationOverlay
      class: 
        label: 
          en: Name of the base
          de: der vergebene Name
      attributes:
        person: 
          label: 
            en: Person
            de:
              - die Person
              - der Mensch
        dateOfBirth: 
          label: 
            en: Date of Birth 
            de: Geburtsdatum
          comment: 
            en: Birthdate of Person
```

*Hint:* use the command `soya template annotation` to show an example on the command line

<details>
  <summary>Output</summary>

Use the following command to generate the output:    
```bash
soya template annotation | soya init
```

```json-ld
{
  "@context": {
    "@version": 1.1,
    "@import": "https://ns.ownyourdata.eu/ns/soya-context.json",
    "@base": "https://soya.data-container.net/PersonAnnotation/"
  },
  "@graph": [
    {
      "@id": "Person",
      "label": {
        "en": [
          "Person"
        ],
        "de": [
          "die Person",
          "der Mensch"
        ]
      }
    },
    {
      "@id": "name",
      "label": {
        "en": [
          "Name"
        ],
        "de": [
          "Name"
        ]
      }
    },
    {
      "@id": "dateOfBirth",
      "label": {
        "en": [
          "Date of Birth"
        ],
        "de": [
          "Geburtsdatum"
        ]
      },
      "comment": {
        "en": [
          "Birthdate of Person"
        ]
      }
    },
    {
      "@id": "sex",
      "label": {
        "en": [
          "Gender"
        ],
        "de": [
          "Geschlecht"
        ]
      },
      "comment": {
        "en": [
          "Gender (male or female)"
        ],
        "de": [
          "Geschlecht (männlich oder weiblich)"
        ]
      }
    },
    {
      "@id": "OverlayAnnotation",
      "@type": "OverlayAnnotation",
      "onBase": "Person",
      "name": "PersonAnnotationOverlay"
    }
  ]
}
```

</details>

#### Format

The *Format* overlay defines how data is presented to the user. In YAML it has the following format:

```yaml
meta:
  name: SampleFormat

content:
  overlays: 
    - type: OverlayFormat
      base: NameOfBase
      name: SampleFormatOverlay
      attributes:
        dateOfBirth: DD/MM/YYYY
```

*Hint:* use the command `soya template format` to show an example on the command line

<details>
  <summary>Output</summary>

Use the following command to generate the output:    
```bash
soya template format | soya init
```

```json-ld
{
  "@context": {
    "@version": 1.1,
    "@import": "https://ns.ownyourdata.eu/ns/soya-context.json",
    "@base": "https://soya.data-container.net/PersonFormat/"
  },
  "@graph": [
    {
      "@id": "dateOfBirth",
      "format": "DD/MM/YYYY"
    },
    {
      "@id": "OverlayFormat",
      "@type": "OverlayFormat",
      "onBase": "Person",
      "name": "PersonFormatOverlay"
    }
  ]
}
```

</details>

#### Encoding

The *Encoding* overlay specifies the character set encoding used in storing the data of an instance (e.g., UTF-8). In YAML it has the following format:

```yaml
meta:
  name: SampleEncoding

content:
  overlays: 
    - type: OverlayEncoding
      base: NameOfBase    
      name: SampleEncodingOverlay
      attributes:
        name: UTF-8
        company: ASCII
```

*Hint:* use the command `soya template encoding` to show an example on the command line

<details>
  <summary>Output</summary>

Use the following command to generate the output:    
```bash
soya template encoding | soya init
```

```json-ld
{
  "@context": {
    "@version": 1.1,
    "@import": "https://ns.ownyourdata.eu/ns/soya-context.json",
    "@base": "https://soya.data-container.net/PersonEncoding/"
  },
  "@graph": [
    {
      "@id": "name",
      "encoding": "UTF-8"
    },
    {
      "@id": "dateOfBirth",
      "encoding": "UTF-8"
    },
    {
      "@id": "age",
      "encoding": "UTF-8"
    },
    {
      "@id": "sex",
      "encoding": "UTF-8"
    },
    {
      "@id": "OverlayEncoding",
      "@type": "OverlayEncoding",
      "onBase": "Person",
      "name": "PersonEncodingOverlay"
    }
  ]
}
```

</details>

#### Form

The *Form* overlay allows to configure rendering HTML forms for visualizing and editing instances. In YAML it has the following format:

```yaml
meta:
  name: SampleEncoding

content:
  overlays: 
    - type: OverlayEncoding
      base: NameOfBase    
      name: SampleEncodingOverlay
      attributes:
        name: UTF-8
        company: ASCII
meta:
  name: SampleForm

content:
  overlays: 
    - type: OverlayForm
      base: NameOfBase
      name: SampleFormOverlay
      schema:
        type: object
        properties:
          name:
            type: string
          dateOfBirth:
            type: string
            format: date
        required: []
      ui:
        type: VerticalLayout
        elements:
        - type: Group
          label: Person
          elements:
          - type: Control
            scope: "#/properties/name"
          - type: Control
            scope: "#/properties/dateOfBirth"

```

*Hint:* use the command `soya template form` to show an example on the command line

<details>
  <summary>Output</summary>

Use the following command to generate the output:    
```bash
soya template form | soya init
```

```json-ld
{
  "@context": {
    "@version": 1.1,
    "@import": "https://ns.ownyourdata.eu/ns/soya-context.json",
    "@base": "https://soya.data-container.net/Person/"
  },
  "@graph": [
    {
      "@id": "PersonForm",
      "schema": {
        "type": "object",
        "properties": {
          "name": {
            "type": "string"
          },
          "dateOfBirth": {
            "type": "string",
            "format": "date"
          }
        },
        "required": []
      },
      "ui": {
        "type": "VerticalLayout",
        "elements": [
          {
            "type": "Group",
            "label": "Person",
            "elements": [
              {
                "type": "Control",
                "scope": "#/properties/name"
              },
              {
                "type": "Control",
                "scope": "#/properties/dateOfBirth"
              }
            ]
          }
        ]
      },
      "@type": "OverlayForm",
      "onBase": "Person",
      "name": "PersonFormOverlay"
    }
  ]
}
```

</details>

#### Classification

The *Classification* overlay identifies a subset of available attributes for some purpose (e.g., personally identifiable information, configuring a list view). In YAML it has the following format:

```yaml
meta:
  name: SampleClassification

content:
  overlays: 
    - type: OverlayClassification
      base: NameOfBase
      name: SampleClassificationOverlay
      attributes:
        name: class1
        dateOfBirth: class1
        sex: 
          - class1
          - class2
```

*Hint:* use the command `soya template classification` to show an example on the command line

<details>
  <summary>Output</summary>

Use the following command to generate the output:    
```bash
soya template classification | soya init
```

```json-ld
{
  "@context": {
    "@version": 1.1,
    "@import": "https://ns.ownyourdata.eu/ns/soya-context.json",
    "@base": "https://soya.data-container.net/PersonClassification/"
  },
  "@graph": [
    {
      "@id": "name",
      "classification": [
        "pii"
      ]
    },
    {
      "@id": "dateOfBirth",
      "classification": [
        "pii"
      ]
    },
    {
      "@id": "sex",
      "classification": [
        "pii",
        "gdpr_sensitive"
      ]
    },
    {
      "@id": "OverlayClassification",
      "@type": "OverlayClassification",
      "onBase": "Person",
      "name": "PersonClassificationOverlay"
    }
  ]
}
```

</details>

#### Alignment

The *Alignment* overlay allows to reference existing RDF definitions (e.g. foaf); this also includes declaring a derived base so that attributes can be pre-filled from a data store holding a record with that base (e.g., don’t require first name, last name to be entered but filled out automatically). In YAML it has the following format:

```yaml
meta:
  name: SampleAlignment
  namespace:
    foaf: "http://xmlns.com/foaf/0.1/"
    dc: "http://purl.org/dc/elements/1.1/"

content:
  overlays: 
    - type: OverlayAlignment
      base: NameOfBase
      name: SampleAlignmentOverlay
      attributes:
        name: 
          - foaf:name
          - dc:title
        sex: foaf:gender
```

*Hint:* use the command `soya template alignment` to show an example on the command line

<details>
  <summary>Output</summary>

Use the following command to generate the output:    
```bash
soya template alignment | soya init
```

```json-ld
{
  "@context": {
    "@version": 1.1,
    "@import": "https://ns.ownyourdata.eu/ns/soya-context.json",
    "@base": "https://soya.data-container.net/PersonAlignment/",
    "foaf": "http://xmlns.com/foaf/0.1/",
    "dc": "http://purl.org/dc/elements/1.1/"
  },
  "@graph": [
    {
      "@id": "name",
      "rdfs:subPropertyOf": [
        "foaf:name",
        "dc:title"
      ]
    },
    {
      "@id": "sex",
      "rdfs:subPropertyOf": [
        "foaf:gender"
      ]
    },
    {
      "@id": "OverlayAlignment",
      "@type": "OverlayAlignment",
      "onBase": "Person",
      "name": "PersonAlignmentOverlay"
    }
  ]
}
```

</details>

#### Validation

The *Validation* overlay allows to specify for each attribute in a base range selection, valid options, any other validation methods. Through validation a given JSON-LD record (or an array of records) can be validated against a SOyA structure that includes an validation overlay. Currently, SHACL ([Shapes Constraint Language](https://en.wikipedia.org/wiki/SHACL)) is used in validation overlays. In YAML it has the following format:

```yaml
meta:
  name: SampleValidation

content:
  overlays: 
    - type: OverlayValidation
      base: NameOfBase
      name: SampleValidationOverlay
      attributes:
        name: 
          cardinality: "1..1"
          length: "[0..20)"
          pattern: "^[A-Za-z ,.'-]+$"
        dateOfBirth:
          cardinality: "1..1"
          valueRange: "[1900-01-01..*]"                    
        age: 
          cardinality: "0..1"
          valueRange: "[0..*]"
        sex:
          cardinality: "0..1"
          valueOption:
            - male
            - female
            - other
```

*Hint:* use the command `soya template validation` to show an example on the command line

<details>
  <summary>Output</summary>

Use the following command to generate the output:    
```bash
soya template validation | soya init
```

```json-ld
{
  "@context": {
    "@version": 1.1,
    "@import": "https://ns.ownyourdata.eu/ns/soya-context.json",
    "@base": "https://soya.data-container.net/PersonValidation/"
  },
  "@graph": [
    {
      "@id": "PersonShape",
      "@type": "sh:NodeShape",
      "sh:targetClass": "Person",
      "sh:property": [
        {
          "sh:path": "name",
          "sh:minCount": 1,
          "sh:maxCount": 1,
          "sh:maxLength": 19,
          "sh:pattern": "^[a-z ,.'-]+$"
        },
        {
          "sh:path": "dateOfBirth",
          "sh:minCount": 1,
          "sh:maxCount": 1,
          "sh:minRange": {
            "@type": "xsd:date",
            "@value": "1900-01-01"
          }
        },
        {
          "sh:path": "age",
          "sh:maxCount": 1
        },
        {
          "sh:path": "sex",
          "sh:maxCount": 1,
          "sh:in": {
            "@list": [
              {
                "label": {
                  "en": "Female",
                  "de": "Weiblich"
                },
                "@id": "female"
              },
              "male",
              "other"
            ]
          }
        }
      ],
      "onBase": "Person",
      "name": "PersonValidationOverlay"
    }
  ]
}
```

</details>

#### Transformation

The *Transformation* overlay define a set of transformation rules for a data record. Transformations allow to convert a JSON-LD record (or an array of records) with a well-defined data model (based on a SOyA structure) into another data model using information from a tranformation overlay. Currently, [`jq`](https://stedolan.github.io/jq/) and [`Jolt`](https://github.com/bazaarvoice/jolt/#jolt) are available engines for transformation overlays. 

In YAML a transformation overlay for `jq` has the following format:

```yaml
meta:
  name: Sample_jq_transformation

content:
  overlays: 
    - type: OverlayTransformation
      name: SampleJqTransformationOverlay
      base: NameOfBase
      engine: jq
      value: |
        .["@graph"] | 
        {
          "@context": {
            "@version":1.1,
            "@vocab":"https://soya.data-container.net/PersonB/"},
          "@graph": map( 
            {"@id":.["@id"], 
            "@type":"PersonB", 
            "first_name":.["basePerson:firstname"], 
            "surname":.["basePerson:lastname"], 
            "birthdate":.["basePerson:dateOfBirth"], 
            "gender":.["basePerson:sex"]}
          )
        }
```

*Hint:* use the command `soya template transformation.jq` to show an example on the command line

<details>
  <summary>Output</summary>

Use the following command to generate the output:    
```bash
soya template transformation.jq | soya init
```

```json-ld
{
  "@context": {
    "@version": 1.1,
    "@import": "https://ns.ownyourdata.eu/ns/soya-context.json",
    "@base": "https://soya.data-container.net/PersonA_jq_transformation/"
  },
  "@graph": [
    {
      "@id": "PersonATransformation",
      "engine": "jq",
      "value": ".[\"@graph\"] | \n{\n  \"@context\": {\n    \"@version\":1.1,\n    \"@vocab\":\"https://soya.data-container.net/PersonB/\"},\n  \"@graph\": map( \n    {\"@id\":.[\"@id\"], \n    \"@type\":\"PersonB\", \n    \"first_name\":.[\"basePerson:firstname\"], \n    \"surname\":.[\"basePerson:lastname\"], \n    \"birthdate\":.[\"basePerson:dateOfBirth\"], \n    \"gender\":.[\"basePerson:sex\"]}\n  )\n}\n",
      "@type": "OverlayTransformation",
      "onBase": "PersonA",
      "name": "TransformationOverlay"
    }
  ]
}
```

</details>


In YAML a transformation overlay for `Jolt` has the following format:

```yaml
meta:
  name: Sample_jolt_Transformation

content:
  overlays: 
    - type: OverlayTransformation
      name: SampleJoltTransformationOverlay
      base: PersonA
      engine: jolt
      value:
        - operation: shift
          spec: 
            "\\@context":
              "\\@version": "\\@context.\\@version"
              "#https://soya.data-container.net/PersonB/": "\\@context.\\@vocab"
            "\\@graph": 
              "*": 
                "#PersonB": "\\@graph[#2].\\@type"
                "\\@id": "\\@graph[#2].\\@id"
                "basePerson:firstname": "\\@graph[#2].first_name"
                "basePerson:lastname": "\\@graph[#2].surname"
                "basePerson:dateOfBirth": "\\@graph[#2].birthdate"
                "basePerson:sex": "\\@graph[#2].gender"
```

*Hint:* use the command `soya template transformation.jolt` to show an example on the command line

<details>
  <summary>Output</summary>

Use the following command to generate the output:    
```bash
soya template transformation.jolt | soya init
```

```json-ld
{
  "@context": {
    "@version": 1.1,
    "@import": "https://ns.ownyourdata.eu/ns/soya-context.json",
    "@base": "https://soya.data-container.net/PersonA_jolt_Transformation/"
  },
  "@graph": [
    {
      "@id": "PersonATransformation",
      "engine": "jolt",
      "value": [
        {
          "operation": "shift",
          "spec": {
            "\\@context": {
              "\\@version": "\\@context.\\@version",
              "#https://soya.data-container.net/PersonB/": "\\@context.\\@vocab"
            },
            "\\@graph": {
              "*": {
                "#PersonB": "\\@graph[#2].\\@type",
                "\\@id": "\\@graph[#2].\\@id",
                "basePerson:firstname": "\\@graph[#2].first_name",
                "basePerson:lastname": "\\@graph[#2].surname",
                "basePerson:dateOfBirth": "\\@graph[#2].birthdate",
                "basePerson:sex": "\\@graph[#2].gender"
              }
            }
          }
        }
      ],
      "@type": "OverlayTransformation",
      "onBase": "PersonA",
      "name": "TransformationOverlay"
    }
  ]
}
```

</details>

## 2. Publishing Structures

### Transform YAML to JSON-LD (`soya init`)

### Upload to Repository (`soya push`)

### Get Information (`soya info`)

### Compare with Existing Structure (`soya similar`)

### Download from Repository (`soya pull`)

### Use JSON-LD Playground (`soya playground`)

## 3. Working with Instances

### Transform flat-JSON Records into JSON-LD (`soya acquire`)

### Validate Record against a Structure (`soya validate`)

### Transfrom Instances between Structures (`soya transform`)

### Store Instances in a Semantic Container (`soya push`)

## 4. Editing SOyA Instances in HTML Forms

### JSON Forms Engine (`soya form`)

### Configure Forms Rendering

### Semantic Container and SOyA


&nbsp;    