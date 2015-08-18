# Copyright 2015 Thilo Wehrmann
#
# LICENSE: xxx

FROM ubuntu
MAINTAINER Thilo Wehrmann "thilo.wehrmann@conabio.gob.mx"

RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
RUN gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
RUN gpg -a --export E084DAB9 | sudo apt-key add -

RUN apt-get update
RUN apt-get -y install  git
RUN apt-get update && apt-get install -y   libxml2-dev   python   build-essential   make    gcc    python-dev     locales   python-pip postgresql-server-dev-9.3

#RUN dpkg-reconfigure locales && locale-gen C.UTF-8 &&   /usr/sbin/update-locale LANG=C.UTF-8
#ENV LC_ALL C.UTF-8

RUN apt-get -y install r-base r-base-dev python-rpy2 python-psycopg2

ENV REPORT_DEF /myapp/python_adapter/reporting/report_def.yaml
ENV APP_SETTINGS config.DevelopmentConfig
ENV R_REPORTING_DIR /myapp/cliente_general
ENV R_REPORTING_CONFIG /myapp/config/database.yml

RUN git clone https://github.com/twehrmann/reporting.git /myapp
WORKDIR /myapp/cliente_general
RUN Rscript requirements.R

WORKDIR /myapp/python_adapter
RUN pip install -r requirements.txt

EXPOSE 5555:5555 

WORKDIR /myapp/python_adapter/reporting
#RUN python app.py
ENTRYPOINT ["gunicorn"]
CMD ["-w", "4", "app:app", "-b 0.0.0.0:5555"]