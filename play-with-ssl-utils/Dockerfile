FROM java:latest

RUN ["wget", "-P", "/etc/apt/sources.list.d", "https://sslmate.com/apt/jessie/sslmate.list"]
RUN ["wget", "-P", "/etc/apt/trusted.gpg.d", "https://sslmate.com/apt/jessie/sslmate.gpg"]
RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "sslmate"]

ADD ssl_and_launch.sh /opt/bin/
RUN ["chmod","o+rx","/opt/bin/ssl_and_launch.sh"]
