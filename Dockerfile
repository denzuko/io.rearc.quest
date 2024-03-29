FROM node:10-alpine

LABEL vendor=Rearc
LABEL org.opencontainers.image.title "rearc.io-quest"
LABEL org.opencontainers.image.description "example deployment for rearc.io quest"
LABEL net.dapla.cmdbapi.orgunit "Platform Dev"
LABEL net.dapla.cmdbapi.organization "Rearc.IO"
LABEL net.dapla.cmdbapi.application "Quest"
LABEL net.dapla.cmdbapi.role "rest api"
LABEL net.dapla.cmdbapi.customer "REARC-01"
LABEL net.dapla.cmdbapi.environment "production"

ARG PORT 3000
ENV PORT=${PORT}
ARG SECRET '1623fafb-b51d-41e0-8d08-6f3ae54f98e8'
ENV SECRET_WORD=${SECRET}
ARG LINT 'yes'
ENV LINT=${LINT}
ARG TEST 'yes'
ENV TEST=${TEST}
EXPOSE ${PORT}

RUN apk update && apk add --update --no-cache \
    --repository=http://dl-cdn.alpinelinux.org/alpine/v3.11/main \
    python3=3.8.2-r2 \
    build-base=0.5-r1 \
    wget=1.20.3-r0 \
    git=2.24.4-r0 \
    bash=5.0.11-r1 \
    ca-certificates=20191127-r2

RUN adduser -D -s /bin/sh -u 1100 runner && sed -i -r 's/^runner:!:/runner:x:/' /etc/shadow

WORKDIR /src

COPY --chown=runner:runner src/package.json /src
COPY --chown=runner:runner src/bin /src
COPY --chown=runner:runner src/src /src

SHELL ["/bin/sh", "-c"]

RUN command -v npx 2>/dev/null || npm install -g npx@10.2.2
RUN npm install

RUN sed -i -r '/^runner:/! s#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd
RUN printf "\n\nApp container image built on %s." "$(date)" > /etc/motd
RUN rm -fr /var/spool/cron /etc/crontabs /etc/periodic
RUN sed -i -r '/^(runner|root|sshd)/!d' /etc/group
RUN sed -i -r '/^(runner|root|sshd)/!d' /etc/passwd
RUN rm -fr /etc/init.d /lib/rc /etc/conf.d /etc/inittab /etc/runlevels /etc/rc.conf
RUN rm -fr /etc/sysctl* /etc/modprobe.d /etc/modules /etc/mdev.conf /etc/acpi /root /etc/fstab

USER runner

HEALTHCHECK --interval=10m --timeout=5s CMD wget -nv -t1 --spider 'http://localhost:${PORT}'
ENTRYPOINT ["npm"]
CMD ["start"]
