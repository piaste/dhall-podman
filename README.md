# `dhall-kubernetes-podman`

This project aims to write minimal, readable, boilerplate-free Kubernetes Deployment files for Podman, using Dhall.

The use case is to replace Docker Compose for Podman usage. Both `podman-compose` and the built-in Podman support for 'native' `docker-compose.yml` files leave quite a lot to be desired.

However, Podman's `podman play kube` command is quite a bit more stable. The only downside is that Kubernetes pods and deployment definitions are notoriously verbose. This is where Dhall comes in.

The project is built on top of [dhall-kubernetes][https://github.com/dhall-lang/dhall-kubernetes/].

## Prerequisites

**NOTE**: `dhall-kubernetes` requires at least version `1.27.0` of [the interpreter](https://github.com/dhall-lang/dhall-haskell)
(version `11.0.0` of the language).