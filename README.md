# Drone-Plugin-Rancher-Deploy
A drone plugin used for Rancher (Kubernetes) deployments.

[![Build Status](https://drone.quving.com/api/badges/Quving/drone-plugin-rancher-deploy/status.svg)](https://drone.quving.com/Quving/drone-plugin-rancher-deploy)

<img src="https://i.imgur.com/Sv1Oqiu.png" width="300"/> <img src="https://i.imgur.com/pAUfyq2.png" width="200"/> <img src="https://i.imgur.com/8uWbpgZ.png" width="350"/>


## What's in this repository?
This repository provides a plugin for [Rancher-Deployment](https://rancher.com/) on [Drone-Ci](https://google.com). Rancher is developer friendly container platform for docker orchestration. Working on any cloud, easy to set up, simple to use.



## Example configuration

### Drone v0.8.*
``` yml
...
- name: deploy
  image: quving/drone-rancher-cicd:latest
  settings:
    stamp: ${DRONE_COMMIT}
    kubernetes_deployment: <YOUR-K8S-DEPLOYMENT>
    kubernetes_namespace: <YOUR-NAMESPACE>
    rancher_url:
      from_secret: <RANCHER_URL>
    rancher_token:
      from_secret: <RANCHER_TOKEN>
  when:
    status: [ success ]
    branch: [ master ]
...
```
