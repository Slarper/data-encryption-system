cryptogen generate --config=./cryptogen-config/org1-crypto.yaml --output="crypto-config"
cryptogen generate --config=./cryptogen-config/org2-crypto.yaml --output="crypto-config"
cryptogen generate --config=./cryptogen-config/orderer-crypto.yaml --output="crypto-config"
configtxgen -profile ChannelUsingRaft -channelID data-sharing-channel -outputBlock ./channel-artifacts/genesis.block  -configPath ./configtxgen/

# run the dockers
docker-compose up -d

for i in {1..5}
do
    echo "try $i-th times"
    osnadmin channel join --channelID data-sharing-channel --config-block ./channel-artifacts/genesis.block -o localhost:7053 --ca-file "./crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem" --client-cert "./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt" --client-key "./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"
    if [ $? -eq 0 ]
    then
        break
    fi
    if [ $i -eq 5 ]
    then
        echo "Failed to join the channel"
        exit 1
    fi
    sleep 1
done

echo $PWD
export FABRIC_CFG_PATH=$PWD/core/core.yaml
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=$PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer channel fetch newest ./channel-artifacts/mychannel.block -c data-sharing-channel --orderer orderer.example.com:7050