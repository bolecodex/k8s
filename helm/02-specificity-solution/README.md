# Introduction
Use helm template command to fix the following issues:

```
helm template 02-exercises/02-specificity
```

## Issue 1
Create a new values file to override hpa metadata name with `mycustomhpa`.

*SOLUTION:* `helm template -f 02-exercises/02-specificity-solution/values.custom.yaml 02-exercises/02-specificity-solution`

## Issue 2
Perform the same override using also the command line and assigning `commandLineHpa` to override the name.

*SOLUTION:* `helm template -f 02-exercises/02-specificity-solution/values.custom.yaml 02-exercises/02-specificity-solution --set name=commandLineHpa`
