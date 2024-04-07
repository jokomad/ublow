
FROM golang:bullseye AS easy-novnc-build
WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

FROM ubuntu:22.04 AS chromeinstall

LABEL maintainer "MontFerret Team <mont.ferret@gmail.com>"
LABEL homepage "https://www.montferret.dev/"

EXPOSE 9222

# https://omahaproxy.appspot.com/
# https://chromiumdash.appspot.com/releases?platform=Linux
ENV REVISION=1097615
ENV DOWNLOAD_HOST=https://storage.googleapis.com

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tint2 tigervnc-standalone-server supervisor && \
    rm -rf /var/lib/apt/lists



COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY supervisord.conf /etc/
COPY menu.xml /etc/xdg/openbox/
RUN echo 'hsetroot -solid "#123456" &' >> /etc/xdg/openbox/autostart



RUN mkdir -p /root/.config/tint2
COPY tint2rc /root/.config/tint2/



EXPOSE 8080
ENTRYPOINT ["/bin/bash", "-c", "/usr/bin/supervisord"]

