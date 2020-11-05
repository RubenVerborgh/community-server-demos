#!/usr/bin/env bash

# 1. Install Community Solid Server
#----------------------------------
npm i -g @solid/community-server@0.1.1

## Alternatively, you can run it from source
# git clone git@github.com:solid/community-server.git community-solid-server
# cd community-solid-server
# git checkout v0.1.1
# npm ci
# npm link
# cd ..


# 2. Run Community Solid Server in the background
# -----------------------------------------------
community-solid-server &


# 3. Make sure the server is running
# ----------------------------------
curl http://localhost:3000/
curl http://localhost:3000/ -i


# 4. Upload a profile document
# ----------------------------
cat ruben.ttl
curl -X PUT -H "Content-Type: text/turtle" -T ruben.ttl http://localhost:3000/profile.ttl


# 5. Read the profile document
# ----------------------------
curl http://localhost:3000/profile.ttl
curl http://localhost:3000/profile.ttl -H "Accept: application/n-triples"
curl http://localhost:3000/profile.ttl -H "Accept: application/ld+json"


# 6. Patch the profile document
# ----------------------------
cat add-friend.sparql
curl -X PATCH -H "Content-Type: application/sparql-update" -T add-friend.sparql http://localhost:3000/profile.ttl
curl http://localhost:3000/profile.ttl -H "Accept: application/ld+json"


# 7. Read and convert an HTML+RDFa document
# -----------------------------------------
curl -s https://csarven.ca/linked-research-decentralised-web > thesis.html
curl -X PUT -H "Content-Type: text/html" -T thesis.html http://localhost:3000/thesis.html
curl -s http://localhost:3000/thesis.html | wc -l
curl -s http://localhost:3000/thesis.html -H "Accept: text/turtle"
curl -s http://localhost:3000/thesis.html -H "Accept: application/n-triples" | wc -l


# 7. Read and convert a large Turtle file
# -----------------------------------------
curl -L https://github.com/RubenVerborgh/Solid-World-September-2020/raw/master/scenario/infobox.ttl.gz > infobox.ttl.gz
gunzip < infobox.ttl.gz | wc -l
gunzip < infobox.ttl.gz | curl -X PUT -H "Content-Type: text/turtle" -T - http://localhost:3000/large.ttl
curl -s http://localhost:3000/large.ttl | wc -l
