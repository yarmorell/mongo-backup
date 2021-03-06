FROM ubuntu:16.04
MAINTAINER Yaroslav

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
RUN echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
    mongodb-org* \
    cron \
    rsync

RUN mkdir /var/backup

ENV CRON_TIME_ONE_HOUR="0 */1 * * *"
ENV CRON_TIME_TWO_HOUR="30 */2 * * *"

ADD run.sh /root/run.sh
VOLUME ["/var/backup_one_hour"]
VOLUME ["/var/backup_two_hour"]
RUN chmod +x /root/run.sh
ENTRYPOINT ["/root/run.sh"]
