# CCPBioSim QM/MM Workshop

[![ci](https://github.com/ccpbiosim/qmmm-workshop/actions/workflows/build.yaml/badge.svg?branch=main)](https://github.com/ccpbiosim/qmmm-workshop/actions/workflows/build.yaml)
[![latest](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fccpbiosim.github.io%2Fworkshop.json&query=%24.containers.qmmm-workshop.latest&labelColor=grey&logo=github&logoColor=white&label=latest&color=purple)](https://github.com/ccpbiosim/qmmm-workshop/pkgs/container/qmmm-workshop)
[![issues](https://img.shields.io/github/issues/ccpbiosim/qmmm-workshop?logo=github&labelColor=grey)](https://github.com/CCPBioSim/qmmm-workshop/issues)
[![pr](https://img.shields.io/github/issues-pr/ccpbiosim/qmmm-workshop?logo=github&labelColor=grey)](https://github.com/CCPBioSim/qmmm-workshop/pulls)

This workshop source repository contains the build recipe for a docker container derived from the CCPBioSim JupyterHub image. This container adds the necessary software packages and notebook content to form a deployable course container.

## How to Use

This training course is deployed on the [CCPBioSim](www.ccpbiosim.ac.uk) website via our cloud infrastructure, however you can deploy on your own machine with docker.

Pull the container from our repository::

    docker pull ghcr.io/ccpbiosim/qmmm-workshop:latest

In our containers we are using the JupyterHub default port 8888, so you should
forward this port when deploying locally::

    docker run -p 8888:8888 ghcr.io/ccpbiosim/qmmm-workshop:latest

## Authors

Workshop Content Authors:

- Marc van der Kamp

## Contact

Please direct all questions and feedback to [Charlie Laughton](mailto:Marc.VanderKamp@bristol.ac.uk)
