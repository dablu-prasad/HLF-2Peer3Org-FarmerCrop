#!/bin/bash

# imports  

. scripts/utils.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

: ${CONTAINER_CLI:="docker"}
: ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}
infoln "Using ${CONTAINER_CLI} and ${CONTAINER_CLI_COMPOSE}"

if [ ! -d "channel-artifacts" ]; then
	mkdir channel-artifacts
fi

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
export PEER0_FARMER_CA=${PWD}/organizations/peerOrganizations/farmer.example.com/tlsca/tlsca.farmer.example.com-cert.pem
export PEER0_MILL_CA=${PWD}/organizations/peerOrganizations/mill.example.com/tlsca/tlsca.mill.example.com-cert.pem
export PEER0_WHOLESELLER_CA=${PWD}/organizations/peerOrganizations/wholeseller.example.com/tlsca/tlsca.wholeseller.example.com-cert.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

createChannelGenesisBlock() {
	which configtxgen
	if [ "$?" -ne 0 ]; then
		fatalln "configtxgen tool not found."
	fi
	set -x
	configtxgen -profile ThreeOrgsApplicationGenesis -outputBlock ./channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
	res=$?
	{ set +x; } 2>/dev/null
  verifyResult $res "Failed to generate channel configuration transaction..."
}

createChannel() {
	 setGlobals 1
	local rc=1
	local COUNTER=1
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		osnadmin channel join --channelID $CHANNEL_NAME --config-block ./channel-artifacts/${CHANNEL_NAME}.block -o localhost:7053 --ca-file "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem" --client-cert "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt" --client-key "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key" >&log.txt
		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
}

# joinChannel ORG
joinChannel() {
  FABRIC_CFG_PATH=$PWD/../config/
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
   peer channel join -b $BLOCKFILE >&log.txt
    res=$?
    { set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

setAnchorPeer() {
  ORG=$1
  ${CONTAINER_CLI} exec cli ./scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME 
}

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="FarmerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_FARMER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmer.example.com/users/Admin@farmer.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    # export CORE_PEER_ADDRESS=localhost:8051

  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="MillMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MILL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/mill.example.com/users/Admin@mill.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    # export CORE_PEER_ADDRESS=localhost:10051

  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="WholesellerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_WHOLESELLER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/wholeseller.example.com/users/Admin@wholeseller.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
    # export CORE_PEER_ADDRESS=localhost:12051

  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}

FABRIC_CFG_PATH=${PWD}/configtx

## Create channel genesis block
infoln "Generating channel genesis block '${CHANNEL_NAME}.block'"
createChannelGenesisBlock

FABRIC_CFG_PATH=$PWD/../config/
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"

## Create channel
infoln "Creating channel ${CHANNEL_NAME}"
createChannel
successln "Channel '$CHANNEL_NAME' created"

## Join all the peers to the channel
infoln "Joining farmer peer to the channel..."
joinChannel 1
infoln "Joining mill peer to the channel..."
joinChannel 2
infoln "Joining wholeseller peer to the channel..."
joinChannel 3

## Set the anchor peers for each org in the channel
infoln "Setting anchor peer for farmer..."
setAnchorPeer 1
infoln "Setting anchor peer for mill..."
setAnchorPeer 2
infoln "Setting anchor peer for farmer..."
setAnchorPeer 3

successln "Channel '$CHANNEL_NAME' joined"
