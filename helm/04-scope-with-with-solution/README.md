# Introduction
Use helm template command to fix the following issues:

```
helm template 02-exercises/04-scope-with-with
```

## Issue 1
Use the with keyword to create a scope and make references to values shorter.

*HINT:* Use $.Values when necessary.

*SOLUTION:* $ is used to access the root scope.

## Issue 2
Try removing the full hpa section in `values.yaml`. What happens?

*SOLUTION:* If the object referenced by the with statements is falsy, the block is not included. With evaluates the expression it receives.
