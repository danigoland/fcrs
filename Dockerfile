FROM danigoland/py36-alpine-llvm6 as stage_0
MAINTAINER Dani Goland <glossman@gmail.com>


COPY requirements.txt requirements.txt
COPY requirements-c.txt requirements-c.txt

RUN apk add --no-cache --virtual .build-deps \
  build-base postgresql-dev libffi-dev unzip openblas-dev freetype-dev pkgconfig gfortran snappy g++ snappy-dev libedit-dev \
  && ln -s /usr/include/locale.h /usr/include/xlocale.h && pip install --no-cache-dir -r requirements-c.txt \
  && pip install --no-cache-dir -r requirements.txt \
    && find /usr/local \
        \( -type d -a -name test -o -name tests \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
        -exec rm -rf '{}' + \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
                | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                | sort -u \
                | xargs -r apk info --installed \
                | sort -u \
    )" \
    && apk add --virtual .rundeps $runDeps tzdata tini \
    && apk del .build-deps && rm requirements.txt && rm requirements-c.txt


FROM python:3.6-alpine
COPY --from=stage_0 /usr/local/lib/python3.6/site-packages /usr/local/lib/python3.6/site-packages
COPY --from=stage_0 /usr/lib/libLLVM-6.0.so /usr/lib/libLLVM-6.0.so
COPY --from=stage_0 "/usr/lib/libstdc++.so.6.0.22" "/usr/lib/libstdc++.so.6"
COPY --from=stage_0 "/usr/lib/libgcc_s.so.1" "/usr/lib/libgcc_s.so.1"
COPY --from=stage_0 "/usr/lib/libopenblasp-r0.3.0.dev.so" "/usr/lib/libopenblas.so.3"
COPY --from=stage_0 "/usr/lib/libgfortran.so.3.0.0" "/usr/lib/libgfortran.so.3"
COPY --from=stage_0 "/usr/lib/libquadmath.so.0.0.0" "/usr/lib/libquadmath.so.0"
COPY --from=stage_0 "/usr/lib/libsnappy.so.1.3.1" "/usr/lib/libsnappy.so.1"
COPY --from=stage_0 /usr/local/bin/celery /usr/local/bin/flower /usr/local/bin/cython /usr/local/bin/gunicorn /usr/local/bin/pyjwt /usr/local/bin/
RUN apk add --no-cache py3-psycopg2 tzdata tini py3-psutil \
    && cp -R /usr/lib/python3.6/site-packages/psycopg2/ /usr/local/lib/python3.6/site-packages/ && \
    cp usr/lib/python3.6/site-packages/psycopg2-2.7.5-py3.6.egg-info usr/local/lib/python3.6/site-packages/psycopg2-2.7.5-py3.6.egg-info && rm usr/lib/python3.6/site-packages/psycopg2-2.7.5-py3.6.egg-info \
    && rm -r /usr/lib/python3.6/site-packages/psycopg2/ \
    && cp -R /usr/lib/python3.6/site-packages/psutil/ /usr/local/lib/python3.6/site-packages/ && \
    cp usr/lib/python3.6/site-packages/psutil-5.4.6-py3.6.egg-info usr/local/lib/python3.6/site-packages/psutil-5.4.6-py3.6.egg-info && rm usr/lib/python3.6/site-packages/psutil-5.4.6-py3.6.egg-info \
    && rm -r /usr/lib/python3.6/site-packages/psutil/

CMD ["python"]
