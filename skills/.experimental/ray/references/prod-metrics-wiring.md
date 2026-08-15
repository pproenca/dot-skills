---
title: Wire Prometheus and Grafana into the dashboard
tags: prod, observability, prometheus, grafana
---

## Wire Prometheus and Grafana into the dashboard

The Ray dashboard does not store metrics — its time-series panels are empty until an external Prometheus scrapes the cluster and Grafana renders it back, which surprises anyone who treats the dashboard as batteries-included. On KubeRay the scrape targets are two different things: Ray *pod* metrics are collected by the PodMonitor/ServiceMonitor resources the kube-prometheus-stack setup adds for Ray clusters, while helm's `metrics.serviceMonitor.enabled=true` on the **KubeRay operator** chart scrapes only the operator's own service — setting that flag alone yields no Ray metrics. Then point the dashboard at the backends with `RAY_PROMETHEUS_HOST`, `RAY_GRAFANA_HOST`, and `RAY_GRAFANA_IFRAME_HOST` on the head pod. Pair the metrics with `ray.util.state` for point-in-time introspection; neither replaces the other.

```yaml
headGroupSpec:
  template:
    spec:
      containers:
        - name: ray-head
          env:
            - { name: RAY_PROMETHEUS_HOST, value: "http://prometheus-server.monitoring:9090" }
            - { name: RAY_GRAFANA_HOST, value: "http://grafana.monitoring:3000" }
            - { name: RAY_GRAFANA_IFRAME_HOST, value: "https://grafana.internal.example.com" }
```

Reference: [KubeRay — Prometheus & Grafana integration](https://docs.ray.io/en/latest/cluster/kubernetes/k8s-ecosystem/prometheus-grafana.html)
