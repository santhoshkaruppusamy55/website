set -e
docker pull santhoshkaruppusamy/website:tagname
docker run -d -p 80:80 santhoshkaruppusamy/website
