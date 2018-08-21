FROM danigoland/py36-alpine-llvm6
MAINTAINER Dani Goland <glossman@gmail.com>


COPY requirements.txt requirements.txt
COPY requirements-c.txt requirements-c.txt
COPY pip_installer.sh /


RUN apk add --no-cache --virtual .build-deps \
  build-base postgresql-dev libffi-dev unzip openblas-dev freetype-dev pkgconfig gfortran snappy g++ snappy-dev libedit-dev \
  && ln -s /usr/include/locale.h /usr/include/xlocale.h

RUN pip install --no-cache-dir -r requirements-c.txt

RUN   /pip_installer.sh \
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
    && apk add --virtual .rundeps $runDeps \
    && apk del .build-deps && rm requirements.txt && rm requirements-c.txt
