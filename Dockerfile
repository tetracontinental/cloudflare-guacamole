FROM ubuntu:latest
LABEL maintainer="matt@matthewrogers.org"

ENV HOME=/root
ENV LC_ALL=C.UTF-8
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP.UTF-8
ENV GOPATH=/root/go
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# ファイルの追加と権限設定
ADD setup.sql /root/setup.sql
ADD start.sh /root/start.sh
RUN chmod +x /root/start.sh
RUN mkdir -p /etc/guacamole/lib
ADD guacamole.properties /etc/guacamole/guacamole.properties

# 必要なパッケージのインストール
RUN apt-get update -y && \
    apt-get install -y wget iproute2 mariadb-server libmariadb-java guacd tomcat9 && \
    wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -O /root/cloudflared.deb && \
    dpkg -i /root/cloudflared.deb && \
    rm /root/cloudflared.deb && \
    mkdir /var/run/mysqld && \
    chown -R mysql:root /var/run/mysqld

# Guacamoleクライアントの設定
RUN wget "https://archive.apache.org/dist/guacamole/1.3.0/binary/guacamole-1.3.0.war" -O /var/lib/tomcat9/webapps/guacamole.war && \
    ln -s /etc/guacamole/ /var/lib/tomcat9/.guacamole && \
    mkdir -p /usr/share/tomcat9/logs && \
    ln -s /usr/share/java/mariadb-java-client.jar /etc/guacamole/lib/ && \
    mkdir -p /etc/guacamole/extensions && \
    wget https://archive.apache.org/dist/guacamole/1.3.0/binary/guacamole-auth-jdbc-1.3.0.tar.gz -O /root/guacamole-auth-jdbc-1.3.0.tar.gz && \
    tar xvfz /root/guacamole-auth-jdbc-1.3.0.tar.gz -C /root/ && \
    cp /root/guacamole-auth-jdbc-1.3.0/mysql/guacamole-auth-jdbc-mysql-1.3.0.jar /etc/guacamole/extensions

EXPOSE 8080/tcp

# 起動スクリプトの実行
CMD ["/root/start.sh"]
