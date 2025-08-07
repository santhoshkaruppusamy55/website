set -e
docker pull santhoshkaruppusamy/website
docker run -d -p 80:80 santhoshkaruppusamy/website