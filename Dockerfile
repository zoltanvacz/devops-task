FROM python:3.13.9-alpine

WORKDIR /app

COPY . /app

RUN python3 -m venv .venv &&\
    sh /app/build.sh

EXPOSE 8080

ENTRYPOINT ["sh"]

CMD [ "run.sh" ]