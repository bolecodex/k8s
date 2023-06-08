# Introduction
Use helm template command to fix the following issues:

```
helm template 02-exercises/05-named-template
```

## Issue 1
Use a named template (also called partial) to simplify the hpas definitions.

*HINT:* Check the doc about named templates: https://helm.sh/docs/chart_template_guide/named_templates/

## Issue 2
Iterate the result from *Issue 1* to use a for each loop using helm range

## Bonus Issue
Templatize min and max replica (*minReplicas* and *maxReplicas*) values and ensure min replicas has the default value `1` and max replicas is required and its max values is `10`.

*HINT:* Check the doc about template functions:
 - https://helm.sh/docs/howto/charts_tips_and_tricks/
 - https://helm.sh/docs/chart_template_guide/function_list/
 - https://masterminds.github.io/sprig/ (what helm uses internally)


## Bonus Issue 2
Extract template into a new `templates/_helpers.tpl` file.
