# Introduction
Use helm template command to fix the following issues:

```
helm template 02-exercises/02-specificity
```

## Issue 1
Create a new values file to override hpa metadata name with `mycustomhpa`.

*HINT:* Check helm syntax and use `-f` option.

## Issue 2
Perform the same override using also the command line and assigning `commandLineHpa` to override the name.

*HINT:* Check the `--set` option information (`helm template --help`).
