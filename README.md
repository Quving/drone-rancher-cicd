# Drone-Plugin-Rancher-Deploy
A drone plugin used for Rancher (Kubernetes) deployments.

[![Build Status](https://drone.quving.com/api/badges/Quving/drone-plugin-rancher-deploy/status.svg)](https://drone.quving.com/Quving/drone-plugin-rancher-deploy)

## What's in this repository?
This repository provides a plugin for [Rancher-Deployment](https://rancher.com/) on [Drone-Ci](https://www.drone.io/). Rancher is developer friendly container platform for docker orchestration. Working on any cloud, easy to set up, simple to use.


## Example Configuration

### Docker-Container
```bash
docker run --rm \
    -it \
    -e PLUGIN_RANCHER_TOKEN='token-qvgg6:f4ksxq65sqnrkztnc671xk9nghjcxjdr42g64f6gqvzmp6lmsvdtrx' \
    -e PLUGIN_RANCHER_URL='https://rancher.server.com/v3' \
    -e PLUGIN_RANCHER_CONTEXT='c-m-znt28nds:p-4lzpp' \
    -e PLUGIN_KUBERNETES_DEPLOYMENT='nginx-web-1312' \
    -e PLUGIN_KUBERNETES_NAMESPACE='landingpage' \
    -e PLUGIN_STAMP='test' \
    -e DEBUG='true' \
    image: quving/drone-rancher-cicd:latest
```

### .drone.yml
``` yaml
...
---
kind: pipeline
name: pipeline
type: docker
steps:
- name: build and publish
  image: plugins/docker
  settings:
    repo:
      from_secret: docker_repository
    tags:
      - ${DRONE_BRANCH}
    dockerfile: Dockerfile
    registry:
      from_secret: docker_registry
    username:
      from_secret: docker_username
    password:
      from_secret: docker_password
  when:
    status: [ success ]
    branch: [ master ]

- name: deploy
  image: quving/drone-rancher-cicd:latest
  settings:
    stamp: ${DRONE_COMMIT}
    kubectl_options: --insecure-skip-tls-verify
    kubernetes_deployment: service-api,service-worker
    kubernetes_namespace: ${DRONE_BRANCH}
    rancher_url:
      from_secret: rancher_url
    rancher_token:
      from_secret: rancher_token
    rancher_context:
      from_secret: rancher_context
  when:
    status: [ success ]
    branch: [ master ]
...
```

