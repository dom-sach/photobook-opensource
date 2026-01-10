apiVersion: 1

datasources:
  - name: Prometheus
    uid: PROMETHEUS_DS
    type: prometheus
    access: proxy
    url: http://${alb_dns}/prometheus
    isDefault: true
