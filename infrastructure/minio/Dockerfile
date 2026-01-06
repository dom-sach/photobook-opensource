FROM minio/minio:RELEASE.2024-01-16T16-07-38Z

# Docker potrafi pobrać plik z URL bez curl
ADD https://dl.min.io/client/mc/release/linux-amd64/mc /usr/local/bin/mc
RUN chmod +x /usr/local/bin/mc

COPY minio-init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/bin/sh", "-c", "/init.sh & minio server /data --console-address :9001"]

