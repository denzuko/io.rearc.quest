FROM node:10-alpine AS build
MAINTAINER "Dwight Spencer (@denzuko)"

RUN apk add --update --no-cache python  --virtual build-dep build-base gcc wget git ca-certificates
WORKDIR /src
ADD src /src
RUN npm install
RUN npm run lint
RUN npm run test
RUN npm prune --production

FROM node:10-alpine AS hardened_base
MAINTAINER "Dwight Spencer (@denzuko)"

RUN apk add --update --no-cache wget ca-certificates

# Add runner user
RUN adduser -D -s /bin/sh -u 1000 runner && sed -i -r 's/^runner:!:/runner:x:/' /etc/shadow

# Be informative after successful login.
RUN echo -e "\n\nApp container image built on $(date)." > /etc/motd

# Remove existing crontabs, if any.
RUN rm -fr /var/spool/cron /etc/crontabs /etc/periodic

# Remove world-writable permissions.
RUN find / -xdev -type d -perm +0002 -exec chmod o-w {} + \
    find / -xdev -type f -perm +0002 -exec chmod o-w {} +

# Remove unnecessary user accounts.
RUN sed -i -r '/^(runner|root|sshd)/!d' /etc/group
RUN sed -i -r '/^(runner|root|sshd)/!d' /etc/passwd

# Remove interactive login shell for everybody but user.
RUN sed -i -r '/^runner:/! s#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd
RUN find $sysdirs -xdev -type f -regex '.*-$' -exec rm -f {} +

# Ensure system dirs are owned by root and not writable by anybody else.
RUN find $sysdirs -xdev -type d -exec chown root:root {} \; -exec chmod 0755 {} \;

# Remove all suid files.
RUN find $sysdirs -xdev -type f -a -perm +4000 -delete

# Remove other programs that could be dangerous.
RUN find $sysdirs -xdev \( \
  -name hexdump -o \
  -name chgrp -o \
  -name chmod -o \
  -name chown -o \
  -name ln -o \
  -name od -o \
  -name strings -o \
  -name su \
  \) -delete

# Remove init scripts since we do not use them.
RUN rm -fr /etc/init.d /lib/rc /etc/conf.d /etc/inittab /etc/runlevels /etc/rc.conf

# Remove root homedir, fstab, and kernel tunables since we do not need it.
RUN rm -fr /etc/sysctl* /etc/modprobe.d /etc/modules /etc/mdev.conf /etc/acpi /root /etc/fstab

# Remove broken symlinks (because we removed the targets above).
RUN find $sysdirs -xdev -type l -exec test ! -e {} \; -delete


FROM hardened_base
MAINTAINER "Dwight Spencer (@denzuko)"
LABEL org.opencontainers.image.title rearc.io-quest
LABEL org.opencontainers.image.description example deployment for rearc.io quest
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
EXPOSE ${PORT}

USER runner

COPY --chown=runner:nobody --from=build /src/package.json /src/package-lock.json /src/node_modules bin/ src/ .

HEALTHCHECK --interval=10m --timeout=5s CMD wget -nv -t1 --spider 'http://localhost:${PORT}'
ENTRYPOINT npm
COMMAND start
