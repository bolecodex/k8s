# Introduction
Use helm template command to fix the following issues:

```
helm template 02-exercises/03-built-in-objects
```

## Issue 1
Use Chart and Release built in Objects to define the configmap metadata name.
For example as: "{ChartName}-{ChartVersion}-{ReleaseRevision}"

## Issue 2
Add data to the configmap from `conf/index.html` file.

*HINT:* Use .Files Built-in Object.
