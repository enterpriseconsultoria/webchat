FROM alpine:3.8
MAINTAINER Thiago Montenegro <opencode@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ENV TZ America/Sao_Paulo
ENV LC_ALL pt_BR.UTF-8
ENV LC_CTYPE pt_BR.UTF-8
ENV LANG pt_BR.UTF-8
ENV DISPLAY :1
ENV DISPLAY_WIDTH=1024
ENV DISPLAY_HEIGHT=768
ENV VNCPASSWORD GQQMBP3NLYWBL6CQHY2Y

RUN mkdir -p /app/firefox.default && echo "http://dl-3.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && apk --update add tzdata --no-cache && \
    rm /etc/localtime && ln -s /usr/share/zoneinfo/${TZ} /etc/localtime && echo $TZ > /etc/timezone && \
    apk update upgrade --no-cache && apk add --no-cache dbus wget ca-certificates git sqlite bash python python-dev mariadb-dev postgresql-dev py-pip build-base xvfb x11vnc awesome supervisor xterm libmagic libev-dev libgcrypt-dev libxml2-dev libxslt-dev libffi-dev firefox fontconfig ttf-freefont cython cython-dev && \
    git clone https://github.com/kanaka/noVNC.git /opt/noVNC && \
    git clone https://github.com/kanaka/websockify /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    cd /tmp && wget https://github.com/mozilla/geckodriver/releases/download/v0.21.0/geckodriver-v0.21.0-linux64.tar.gz -O geckodriver.tar.gz && tar zxf geckodriver.tar.gz && mv geckodriver /usr/local/bin && rm geckodriver.tar.gz && \
    rm -rf /opt/noVNC/.git && \
    rm -rf /opt/websockify/.git

ADD /Users/thiago/dev/python/webchat-bin /app/webchat 
COPY bin/whatsapp /usr/local/bin/whatsapp
COPY bin/facebook /usr/local/bin/facebook
COPY /Users/thiago/dev/python/webchat-bin/doc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN x11vnc -storepasswd $VNCPASSWORD /app/webchat/vncpasswd && pip install -r /app/webchat/requirements.txt && cd /app/webchat && python manage.pyc makemigrations && python manage.pyc migrate && python manage.pyc loaddata auth_user && python manage.pyc loaddata chatapp_source && python manage.pyc loaddata group && python manage.pyc loaddata script && python manage.pyc loaddata menu && python manage.pyc loaddata menuitem && python manage.pyc loaddata filter && rm *.json && rm -rf .git && chmod 777 /usr/local/bin/facebook /usr/local/bin/whatsapp && ln -s /app/webchat/scripts /app/webchat/media/scripts && chmod +x /run.sh

RUN cat /app/webchat/doc/build | sh 

RUN rm -rf /root/.cache && apk del build-base && rm /app/webchat/requirements.txt && rm -rf /app/webchat/doc 

EXPOSE 8002
EXPOSE 8059

CMD ["/run.sh"]