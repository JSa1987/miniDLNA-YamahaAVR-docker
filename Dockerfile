ARG BASE_IMAGE
FROM ${BASE_IMAGE:-debian:stable-slim} AS BASE
ARG USE_APT_PROXY

RUN mkdir -p /app
RUN mkdir -p /app/conf
RUN mkdir -p /app/doc

#COPY app/conf/01-apt-proxy /app/conf/

#RUN if [ "${USE_APT_PROXY}" = "Y" ]; then \
#    echo "Builind using apt proxy"; \
#    cp /app/conf/01-apt-proxy /etc/apt/apt.conf.d/01-apt-proxy; \
#    cat /etc/apt/apt.conf.d/01-apt-proxy; \
#  else \
#    echo "Building without apt proxy"; \
#  fi

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN apt-get install autoconf -y
RUN apt-get install autopoint -y
RUN apt-get install libavutil-dev -y
RUN apt-get install libavcodec-dev -y
RUN apt-get install libavformat-dev -y
RUN apt-get install libjpeg-dev -y
RUN apt-get install libsqlite3-dev -y
RUN apt-get install libexif-dev -y
RUN apt-get install libid3tag0-dev -y
RUN apt-get install libogg-dev -y
RUN apt-get install libvorbis-dev -y
RUN apt-get install libflac-dev -y
RUN apt-get install gettext -y
RUN apt-get install git -y
RUN apt-get install wget -y
RUN apt-get install build-essential -y

#RUN if [ "${USE_APT_PROXY}" = "Y" ]; then \
#    echo "Removing apt proxy configuration ..."; \
#    rm /etc/apt/apt.conf.d/01-apt-proxy; \
#    echo ". Done."; \
#  fi

#RUN rm -rf /var/lib/apt/lists/*

COPY README.md /app/doc
COPY LICENSE /app/doc

WORKDIR /tmp
RUN git clone git://git.code.sf.net/p/minidlna/git minidlna-git
WORKDIR /tmp/minidlna-git
RUN cp upnpsoap.c upnpsoap.c_bk
RUN rm upnpsoap.c
COPY /app/upnpsoap.c /tmp/minidlna-git/upnpsoap.c
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install


FROM scratch
COPY --from=base / /
LABEL maintainer="JSa1987 <https://github.com/JSa1987>"

RUN mkdir -p /app/bin
RUN mkdir -p /app/conf

VOLUME /db
VOLUME /log

ENV MINIDLNA_PORT "8200"
ENV MINIDLNA_NETWORK_INTERFACE ""
ENV MINIDLNA_FRIENDLY_NAME ""

ENV MINIDLNA_DIR_A_1 ""
ENV MINIDLNA_DIR_A_2 ""
ENV MINIDLNA_DIR_A_3 ""
ENV MINIDLNA_DIR_A_4 ""
ENV MINIDLNA_DIR_A_5 ""

ENV MINIDLNA_DIR_V_1 ""
ENV MINIDLNA_DIR_V_2 ""
ENV MINIDLNA_DIR_V_3 ""
ENV MINIDLNA_DIR_V_4 ""
ENV MINIDLNA_DIR_V_5 ""

ENV MINIDLNA_DIR_P_1 ""
ENV MINIDLNA_DIR_P_2 ""
ENV MINIDLNA_DIR_P_3 ""
ENV MINIDLNA_DIR_P_4 ""
ENV MINIDLNA_DIR_P_5 ""

ENV MINIDLNA_DIR_CUSTOM_1 ""
ENV MINIDLNA_DIR_CUSTOM_2 ""
ENV MINIDLNA_DIR_CUSTOM_3 ""
ENV MINIDLNA_DIR_CUSTOM_4 ""
ENV MINIDLNA_DIR_CUSTOM_5 ""

ENV MINIDLNA_MERGE_MEDIA_DIRS ""

ENV MINIDLNA_SERIAL ""
ENV MINIDLNA_MODEL_NAME ""
ENV MINIDLNA_MODEL_NUMBER ""

ENV MINIDLNA_ENABLE_INOTIFY ""
ENV MINIDLNA_NOTIFY_INTERVAL ""

ENV MINIDLNA_STRICT_DLNA ""

ENV MINIDLNA_LOG_LEVEL ""

ENV USER_MODE ""

ENV MINIDLNA_ROOT_CONTAINER ""
ENV MINIDLNA_FORCE_SORT_CRITERIA ""

ENV PUID ""
ENV PGID ""

COPY --chown=1000:1000 --chmod=555 app/conf/album-art.conf.snippet /app/conf
COPY  --chown=1000:1000 --chmod=755 app/bin/run-minidlna.sh /app/bin/
WORKDIR /app/bin
ENTRYPOINT ["/app/bin/run-minidlna.sh"]
