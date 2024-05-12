cryptogen generate --config=./cryptogen-config/org1-crypto.yaml --output="crypto-config"
cryptogen generate --config=./cryptogen-config/org2-crypto.yaml --output="crypto-config"
cryptogen generate --config=./cryptogen-config/orderer-crypto.yaml --output="crypto-config"
configtxgen -profile ChannelUsingRaft -channelID data-sharing-channel -outputBlock ./channel-artifacts/genesis.block  -configPath ./configtxgen/
set -x NETWORK_HOME $PWD

# run the dockers
docker-compose up -d

set -x OSN_TLS_CA_ROOT_CERT ./crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
set -x ADMIN_TLS_SIGN_CERT ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
set -x ADMIN_TLS_PRIVATE_KEY ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key
set -x CHANNEL_NAME data-sharing-channel
set -x ORDERER_ADMIN_LISTENADDRESS localhost:7053

sleep 1
osnadmin channel join --channelID data-sharing-channel --config-block ./channel-artifacts/genesis.block -o localhost:7053 --ca-file "./crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem" --client-cert "./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt" --client-key "./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"


osnadmin channel list --channelID $CHANNEL_NAME -o $ORDERER_ADMIN_LISTENADDRESS --ca-file $OSN_TLS_CA_ROOT_CERT --client-cert $ADMIN_TLS_SIGN_CERT --client-key $ADMIN_TLS_PRIVATE_KEY
echo $PWD

set -x FABRIC_CFG_PATH $NETWORK_HOME/core/
set -x CORE_PEER_TLS_ENABLED true
set -x CORE_PEER_LOCALMSPID Org1MSP
set -x CORE_PEER_TLS_ROOTCERT_FILE $NETWORK_HOME/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
set -x CORE_PEER_MSPCONFIGPATH $NETWORK_HOME/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
set -x CORE_PEER_ADDRESS localhost:7051
set -x CORE_PEER_LISTENADDRESS localhost:7051


set -x ORDERER_CA $NETWORK_HOME/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
sleep 1
peer channel fetch config $NETWORK_HOME/channel-artifacts/config.block -c $CHANNEL_NAME -o localhost:7050 --tls --cafile $ORDERER_CA
peer channel join -b $NETWORK_HOME/channel-artifacts/config.block --orderer localhost:7050 --tls --cafile ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
peer channel list --orderer localhost:7050 --tls --cafile $ORDERER_CA

set -x ORDERER_CA $NETWORK_HOME/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

set -x FABRIC_CFG_PATH $NETWORK_HOME/core-org2/
set -x CORE_PEER_TLS_ENABLED true
set -x CORE_PEER_LOCALMSPID Org2MSP
set -x CORE_PEER_TLS_ROOTCERT_FILE $NETWORK_HOME/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
set -x CORE_PEER_MSPCONFIGPATH $NETWORK_HOME/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
set -x CORE_PEER_ADDRESS localhost:9051
set -x CORE_PEER_LISTENADDRESS localhost:9051

echo $CORE_PEER_LISTENADDRESS

sleep 1

peer channel fetch config $NETWORK_HOME/channel-artifacts/config-org2.block -c $CHANNEL_NAME -o localhost:7050 --tls --cafile $ORDERER_CA
# peer channel getinfo -c $CHANNEL_NAME -o localhost:7050 --tls true --cafile $ORDERER_CA
sleep 1
peer channel join -b $NETWORK_HOME/channel-artifacts/config-org2.block --orderer localhost:7050 --tls --cafile ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

peer channel list --orderer localhost:7050 --tls --cafile $ORDERER_CA


# set -x FABRIC_CFG_PATH $NETWORK_HOME/core/
# set -x CORE_PEER_TLS_ENABLED true
# set -x CORE_PEER_LOCALMSPID Org1MSP
# set -x CORE_PEER_TLS_ROOTCERT_FILE $NETWORK_HOME/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
# set -x CORE_PEER_MSPCONFIGPATH $NETWORK_HOME/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
# set -x CORE_PEER_ADDRESS localhost:7051
# set -x CORE_PEER_LISTENADDRESS localhost:7051


# sleep 1
# peer channel fetch config $NETWORK_HOME/channel-artifacts/config.block -c $CHANNEL_NAME -o localhost:7050 --tls --cafile $ORDERER_CA
# peer channel join -b $NETWORK_HOME/channel-artifacts/config.block --orderer localhost:7050 --tls --cafile ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
# peer channel list --orderer localhost:7050 --tls --cafile $ORDERER_CA