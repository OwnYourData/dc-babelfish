# Identity Management with `did:oyd`

*last update: 29 April 2023*  

Text. Refer to the [Tutorial-Overview](https://github.com/OwnYourData/dc-babelfish/tree/main/tutorial) for other aspects.

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

### Using a Webservice
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

In the following sections we are using a DID created with this command:


<!-- Include styles for the tabs -->
<style>
.tab {
  display: none;
}
.tablinks {
  cursor: pointer;
}
</style>

<!-- Create tab links -->
<button class="tablinks" onclick="openTab(event, 'TabCmdline')">Command Line</button>
<button class="tablinks" onclick="openTab(event, 'TabAPI')">API Calls</button>

<!-- Create tab content -->
<div id="TabCmdline" class="tab">
  <h2>Tab 1 Content</h2>
  <p>This is the content for Tab 1.</p>
</div>

<div id="TabAPI" class="tab">
  <h2>Tab 2 Content</h2>
  <p>This is the content for Tab 2.</p>
</div>

<!-- Include the JavaScript to handle tab switching -->
<script>
function openTab(evt, tabName) {
  var i, tabcontent, tablinks;
  tabcontent = document.getElementsByClassName("tab");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }
  document.getElementById(tabName).style.display = "block";
  evt.currentTarget.className += " active";
}

// Set the default active tab on page load
document.getElementsByClassName("tablinks")[0].click();
</script>


[back to top](#)

## 2 - Resolving a DID

* internal format
* W3C format

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
