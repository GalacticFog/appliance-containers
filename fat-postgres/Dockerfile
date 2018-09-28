FROM postgres:9.4

RUN sed -ri "s!^#?(max_connections)\s*=.*!\1 = 600!" /usr/share/postgresql/postgresql.conf.sample

