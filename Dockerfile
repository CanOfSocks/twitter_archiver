FROM python:3-slim-bullseye
RUN apt update && apt upgrade -y && apt install -y bash curl jq ffmpeg sed git --no-install-recommends
RUN apt autopurge -y && apt clean -y

RUN pip install git+https://github.com/HoloArchivists/twspace-dl git+https://github.com/JustAnotherArchivist/snscrape.git

RUN mkdir -p /app/scripts
RUN mkdir -p /app/output

COPY updateJson.sh /app/scripts/updateJson.sh
COPY getMedia.sh /app/scripts/getMedia.sh
COPY startArchivers.sh /app/scripts/startArchivers.sh

#RUN chown -R 1000:1000 /app
RUN chmod -R 755 /app
RUN chmod -R 777 /app/output
RUN chmod +x /app/scripts/updateJson.sh
RUN chmod +x /app/scripts/getMedia.sh
RUN chmod +x /app/scripts/startArchivers.sh

#USER 1000

#RUN pip install git+https://github.com/HoloArchivists/twspace-dl git+https://github.com/JustAnotherArchivist/snscrape.git

WORKDIR /app/output

CMD ["/app/scripts/startArchivers.sh"]
