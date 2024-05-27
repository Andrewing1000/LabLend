FROM python:3.9-alpine3.13

ENV PYTHONUNBUFFERED 1


RUN apk add --no-cache openssl && \
    mkdir -p /etc/ssl/private && mkdir -p /etc/ssl/certs && \
    openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/private/key.pem -out /etc/ssl/certs/cert.pem \
    -days 365 -nodes -subj "/C=US/ST=California/L=San Francisco/O=YourCompany/OU=YourDepartment/CN=localhost" && \
    chmod 600 /etc/ssl/private/key.pem /etc/ssl/certs/cert.pem

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol


RUN chown django-user:django-user /etc/ssl/private/key.pem /etc/ssl/certs/cert.pem

ENV PATH="/py/bin:$PATH"

USER django-user
