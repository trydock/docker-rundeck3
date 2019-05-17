FROM debian:stable-slim

MAINTAINER debuggerboy <debuggerboy@gmail.com>

RUN mkdir -p /usr/share/man/man1/
RUN apt-get -qq update && apt-get install --no-install-recommends -qqy curl net-tools procps netcat git gosu openjdk-8-jre-headless openssh-client uuid-runtime && rm -rf /var/lib/apt/lists/*

ENV TINI_VERSION 0.18.0
ENV TINI_SHA 12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855

RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini && echo "$TINI_SHA  /bin/tini" | sha256sum -c -

ENV RUNDECK_HOME /home/rundeck
ENV RUNDECK_UID 1000
ENV RUNDECK_GID 1000

RUN addgroup --system --gid "$RUNDECK_GID" rundeck && adduser --uid "$RUNDECK_UID" --gid "$RUNDECK_GID" --system --home="$RUNDECK_HOME" --disabled-password rundeck

RUN curl -k -L -o rundeck.deb "https://dl.bintray.com/rundeck/rundeck-deb/rundeck_3.0.22.20190512-1.201905130100_all.deb"
RUN dpkg -i rundeck.deb
RUN rm rundeck.deb && rm /etc/init.d/rundeckd && mkdir -p $RUNDECK_HOME/projects && chown -R rundeck:rundeck $RUNDECK_HOME

COPY rundeck.sh /usr/local/bin/rundeck
RUN chown rundeck:rundeck /usr/local/bin/rundeck && chmod +x /usr/local/bin/rundeck

EXPOSE 4440

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/tini", "--", "/entrypoint.sh"]

CMD ["rundeck"]
