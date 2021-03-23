## deliverrable reuqires node 10, Current is 15.12.0
FROM node:10-alpine

## labeling and Responcable Party
LABEL vendor=Rearc
LABEL org.opencontainers.image.title "rearc.io-quest"
LABEL org.opencontainers.image.description "example deployment for rearc.io quest"
LABEL net.dapla.cmdbapi.orgunit "Platform Dev"
LABEL net.dapla.cmdbapi.organization "Rearc.IO"
LABEL net.dapla.cmdbapi.application "Quest"
LABEL net.dapla.cmdbapi.role "rest api"
LABEL net.dapla.cmdbapi.customer "REARC-01"
LABEL net.dapla.cmdbapi.environment "production"

## Set build args defauls
ARG PORT 3000
ENV PORT=${PORT}
ARG SECRET '1623fafb-b51d-41e0-8d08-6f3ae54f98e8'
ENV SECRET_WORD=${SECRET}
ARG LINT 'yes'
ENV LINT=${LINT}
ARG TEST 'yes'
ENV TEST=${TEST}
EXPOSE ${PORT}

# Install requirements
RUN apk add --update --no-cache python build-base gcc wget git ca-certificates

# Remove interactive login shell for everybody but user.
RUN adduser -D -s /bin/sh -u 1100 runner && sed -i -r 's/^runner:!:/runner:x:/' /etc/shadow

# set workspace, add code, install modules, then run lint and unit tests
WORKDIR /src

COPY --chown=runner:runner src/package.json /src
COPY --chown=runner:runner src/bin /src
COPY --chown=runner:runner src/src /src

SHELL bash

RUN command -v npx 2>/dev/null || npm install -g npx@10.2.2
RUN npm install
#RUN test $LINT == "yes" && npm run lint
#RUN test $TEST == "yes" && npm run test

# harden system
RUN sed -i -r '/^runner:/! s#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd
RUN echo -e "\n\nApp container image built on $(date)." > /etc/motd
RUN rm -fr /var/spool/cron /etc/crontabs /etc/periodic
RUN sed -i -r '/^(runner|root|sshd)/!d' /etc/group
RUN sed -i -r '/^(runner|root|sshd)/!d' /etc/passwd
RUN rm -fr /etc/init.d /lib/rc /etc/conf.d /etc/inittab /etc/runlevels /etc/rc.conf

# Remove root homedir, fstab, and kernel tunables since we do not need it.
RUN rm -fr /etc/sysctl* /etc/modprobe.d /etc/modules /etc/mdev.conf /etc/acpi /root /etc/fstab

## Never run as root
USER runner

## uptime checker
HEALTHCHECK --interval=10m --timeout=5s CMD wget -nv -t1 --spider 'http://localhost:${PORT}'

## npm is good and this is our pid 1
ENTRYPOINT ["npm"]

## can override for sub tasks but we'll just start the server with each instance
CMD ["start"]
