FROM node:18

ARG TINI_VER="v0.19.0"

# install tini
ADD https://github.com/krallin/tini/releases/download/$TINI_VER/tini /sbin/tini
RUN chmod +x /sbin/tini

# install sqlite3

#RUN apt-get update                                                   \
# && apt-get install    --quiet --yes --no-install-recommends sqlite3 \
# && apt-get clean      --quiet --yes                                 \
# && apt-get autoremove --quiet --yes                                 \
# && rm -rf /var/lib/apt/lists/*

RUN echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" > /etc/apt/sources.list
RUN apt update \
	&& apt install -y sqlite3 \
	&& apt clean -y \
	&& apt autoremove -y \
	&& rm -rf /var/lib/apt/lists/*


# copy minetrack files
WORKDIR /usr/src/minetrack
RUN mkdir -p /usr/src/minetrack/data
COPY . .

# build minetrack
RUN npm install \
 && npm run build

# run as non root
RUN addgroup --gid 10043 --system minetrack \
 && adduser  --uid 10042 --system --ingroup minetrack --no-create-home --gecos "" minetrack \
 && chown -R minetrack:minetrack /usr/src/minetrack
USER minetrack

EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--", "node", "main.js"]
