# Demo: Creating Custom Resources
```
cat crd-object.yaml
kubectl create -f crd-object.yaml
kubectl api-resources | grep backup
cat crd-backup.yaml
kubectl create -f crd-backup.yaml
kubectl get backups
```

# Exercise

1. Check the cluster's CRD
```
kubectl get crd --all-namespaces
```

##

2. Check Calico crd
```
kubectl get crd caliconodestatuses.crd.projectcalico.org -o yaml | less
```

##

3. CRD generation
```
cat <<EOF | kubectl create -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  # name must match the spec fields below, and be in the form: <plural>.<group>
  name: crontabs.stable.example.com
spec:
  # group name to use for REST API: /apis/<group>/<version>
  group: stable.example.com
  # list of versions supported by this CustomResourceDefinition
  versions:
    - name: v1
      # Each version can be enabled/disabled by Served flag.
      served: true
      # One and only one version must be marked as the storage version.
      storage: true
      schema:
        openAPIV3Schedule:
          type: object
          properties:
            spec:
              type: object
              properties:
                cronSpec:
                  type: string
                image:
                  type: string
                replicas:
                  type: integer
  # either Namespaced or Cluster
  scope: Namespaced
  names:
    # plural name to be used in the URL: /apis/<group>/<version>/<plural>
    plural: crontabs
    # singular name to be used as an alias on the CLI and for display
    singular: crontab
    # kind is normally the CamelCased singular type. Your resource manifests use this.
    kind: CronTab
    # shortNames allow shorter string to match your resource on the CLI
    shortNames:
    - ct
EOF
```

##

4. CRD confirmation
```
kubectl get crd crontabs.stable.example.com
kubectl describe crd crontabs.stable.example.com
```

##

5. CRD object creation
```
cat <<EOF | kubectl create -f -
apiVersion: "stable.example.com/v1"
    # This is from the group and version of new CRD
kind: CronTab
    # The kind from the new CRD
metadata:
  name: new-cron-object
spec:
  cronSpec: "*/5 * * * *"
  image: some-cron-image
    #Does not exist
EOF
```

##

6. CRD created above - Crontap check
```
kubectl get crontab
kubectl get ct
kubectl describe ct
```

##

7. Delete the created CRD
```
kubectl delete crd crontabs.stable.example.com
```
