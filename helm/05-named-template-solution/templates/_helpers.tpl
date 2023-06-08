{{- define "example.hpa" }}
{{- $name := .name }}
{{- $maxReplicas := required "Max replicas is mandatory" .maxReplicas }}
{{- $maxReplicas = min $maxReplicas 10 }}
{{- $minReplicas := default 1 .minReplicas }}
---
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: {{ $name }}
spec:
  maxReplicas: {{ $maxReplicas }}
  minReplicas: {{ $minReplicas }}
  scaleTargetRef:
    apiVersion: extensions/v1beta1
    kind: Deployment
    name: {{ $name }}
  targetCPUUtilizationPercentage: 85
{{- end }}
