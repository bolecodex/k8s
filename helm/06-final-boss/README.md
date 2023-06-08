# Introduction
The final Boss tells you to use your recently learned helm skills in the real world example which is the `helm-workshop` chart in the root of the repo.

## Issue 1
Use the values.yaml to templatize the container port (containerPort).

## Issue 2
- Replace `nginx` with the following docker image: [aimvector/nodejs](https://hub.docker.com/r/aimvector/nodejs) and version `1.0.0`

- Create a new `values.overwride.yaml` to do the changes.

*HINT:* The image above uses port `5000`.

## Issue 3
Using `nignx` to inject a custom HTML through Helm.

- Use a configmap
- Use volumes

*HINT:* https://stackoverflow.com/a/60427920
