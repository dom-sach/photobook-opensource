#FROM amazonlinux:2023
#
#RUN yum install -y curl ca-certificates && yum clean all
#
#COPY init.sh /init.sh
#RUN chmod +x /init.sh
#
#ENTRYPOINT ["/init.sh"]


#FROM amazonlinux:2023



FROM minio/mc:RELEASE.2024-01-16T16-07-38Z

COPY init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]



#FROM minio/mc:RELEASE.2024-01-16T16-07-38Z
#
#RUN yum install -y curl ca-certificates bash && \
#    curl -sSL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && \
#    chmod +x /usr/local/bin/mc
#
#COPY init.sh /init.sh
#RUN chmod +x /init.sh
#
#ENTRYPOINT ["/init.sh"]
