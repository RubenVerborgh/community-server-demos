#!/usr/bin/env bash

# 1. Install Community Solid Server
#----------------------------------
npm i -g @solid/community-server@0.2.0
CONFIG=`dirname $(which community-solid-server)`/../lib/node_modules/@solid/community-server/config

## Alternatively, you can run it from source
# git clone git@github.com:solid/community-server.git community-solid-server
# cd community-solid-server
# git checkout v0.2.0
# npm ci
# npm link
# CONFIG=`pwd`/config
# cd ..


# 2. Set up file storage
# ----------------------
FILEPATH=/tmp/solid
rm -r $FILEPATH
mkdir $FILEPATH

mkdir $FILEPATH/file
curl https://ruben.verborgh.org/images/ruben.jpg > $FILEPATH/file/ruben.jpg
curl https://ruben.verborgh.org/articles/redecentralizing-the-web/ > $FILEPATH/file/article.html


# 3. Run a SPARQL endpoint
# ------------------------
docker pull tenforce/virtuoso
docker container create --name sparql-endpoint \
  -p 4000:8890 \
  -e SPARQL_UPDATE=true \
  tenforce/virtuoso
docker start sparql-endpoint
SPARQLENDPOINT=http://localhost:4000/sparql


# 3. Run the Community Solid Server
# ---------------------------------
cp -r $CONFIG/ config
cat config/config-path-routing.json
community-solid-server \
  -p 3000 \
  -c config/config-path-routing.json \
  -f $FILEPATH \
  -s $SPARQLENDPOINT \
  &


# 4. Read and write with filesystem storage
# -----------------------------------------
curl -I http://localhost:3000/file/ruben.jpg

cat ruben.ttl
curl -i -X POST --data-binary @- \
  -H 'Content-Type: text/turtle' \
  -H 'Slug: person' \
  http://localhost:3000/file/ < ruben.ttl
curl http://localhost:3000/file/person
curl http://localhost:3000/file/person -H 'Accept: application/ld+json'

cat add-ghent.sparql
curl -X PATCH http://localhost:3000/file/person \
  -H 'Content-Type: application/sparql-update' \
  -T add-ghent.sparql
curl http://localhost:3000/file/person

curl -i -X POST http://localhost:3000/file/ \
  -H 'Content-Type: text/plain' \
  -H 'Slug: diary' \
  --data-raw "Dear diary,

  I'm having a lot of fun with the Solid Community Server!
"
curl http://localhost:3000/file/diary


# 5. Read and write with SPARQL endpoint storage
# ----------------------------------------------
curl -i -X POST --data-binary @- \
  -H 'Content-Type: text/turtle' \
  -H 'Slug: person' \
  http://localhost:3000/sparql/ < ruben.ttl
curl http://localhost:3000/sparql/person -H 'Accept: text/turtle'
curl http://localhost:3000/sparql/person -H 'Accept: application/ld+json'

curl -X PATCH http://localhost:3000/sparql/person \
  -H 'Content-Type: application/sparql-update' \
  -T add-ghent.sparql
curl http://localhost:3000/sparql/person -H 'Accept: text/turtle'

curl $SPARQLENDPOINT \
  -G --data-urlencode 'query=PREFIX : <https://ruben.verborgh.org/profile/#>
CONSTRUCT WHERE {
  :me ?p ?o.
}'


# 6. Stop the SPARQL endpoint
# ---------------------------
docker stop sparql-endpoint
docker rm sparql-endpoint
