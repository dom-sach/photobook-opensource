global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "guestbook-backend"
    metrics_path: "/api/actuator/prometheus"
    static_configs:
      - targets:
          - "${backend_alb_dns}"
