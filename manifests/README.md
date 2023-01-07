# Levar - Openshift Examples

You can create the deployment, the service and the secrets with these commands:

```bash
kubectl create deploy levar --image hectorvido/levar
kubectl expose deploy levar --port 8080
kubectl create secret generic levar --from-env-file levar.env
```

> If you don't use proxy, just remove the variables from the `levar.env` file.

The container follow the best Openshift practices and is user id independent.

Feel free to use the manifests if you want.
