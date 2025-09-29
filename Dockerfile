FROM --platform=linux/amd64 debian:trixie-slim
RUN apt-get update && apt-get install -y tree && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /root/deploy/pg_ext /root/extra_packages
COPY ./pg_ext/. /root/deploy/pg_ext/
COPY ./version /root/deploy/pg_ext/
RUN bash /root/deploy/pg_ext/fix-permissions.sh
COPY ./deploy-from-container.sh /root/deploy.sh
RUN chmod +x /root/deploy.sh
VOLUME /root/extra_packages
RUN tree /root/deploy/pg_ext
ENTRYPOINT ["/root/deploy.sh"]