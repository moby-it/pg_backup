FROM postgres:15.5-bookworm
WORKDIR /src

ENV CONNECTION_STRING=connection_string

RUN apt-get update && apt-get install s3cmd -y

COPY backup.sh backup.sh
COPY connection_string connection_string
COPY .s3cfg /root/.s3cfg

CMD /src/backup.sh
