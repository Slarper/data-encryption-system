docker stop $(docker ps -q)
docker rm $(docker ps -a -q)

rm -rf ./crypto-config
rm -rf ./channel-artifacts