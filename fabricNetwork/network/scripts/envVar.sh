#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
export PEER0_FARMER_CA=${PWD}/organizations/peerOrganizations/farmer.example.com/tlsca/tlsca.farmer.example.com-cert.pem
export PEER0_MILL_CA=${PWD}/organizations/peerOrganizations/mill.example.com/tlsca/tlsca.mill.example.com-cert.pem
export PEER0_WHOLESELLER_CA=${PWD}/organizations/peerOrganizations/wholeseller.example.com/tlsca/tlsca.wholeseller.example.com-cert.pem
# export PEER0_FARMER_CA=${PWD}/organizations/peerOrganizations/farmer.example.com/peers/farmer.example.com/tls/ca.crt
# export PEER0_MILL_CA=${PWD}/organizations/peerOrganizations/mill.example.com/peers/mill.example.com/tls/ca.crt
# export PEER0_WHOLESELLER_CA=${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/wholeseller.example.com/tls/ca.crt
# export PEER1_FARMER_CA=${PWD}/organizations/peerOrganizations/farmer.example.com/peers/f1.farmer.example.com/tls/ca.crt
# export PEER1_MILL_CA=${PWD}/organizations/peerOrganizations/mill.example.com/peers/m1.mill.example.com/tls/ca.crt
# export PEER1_WHOLESELLER_CA=${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/w1.wholeseller.example.com/tls/ca.crt
 export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
 export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

# Set environment variables for the peer org
setGlobals() {
  infoln "pppp $OVERRIDE_ORG"
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
  export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="FarmerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_FARMER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmer.example.com/users/Admin@farmer.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

  elif [ $USING_ORG -eq 2 ]; then
  export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="MillMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MILL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/mill.example.com/users/Admin@mill.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

  elif [ $USING_ORG -eq 3 ]; then
  export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="WholesellerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_WHOLESELLER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/wholeseller.example.com/users/Admin@wholeseller.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051

  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_LOCALMSPID="FarmerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_FARMER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmer.example.com/users/Admin@farmer.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051  

  elif [ $USING_ORG -eq 5 ]; then
    export CORE_PEER_LOCALMSPID="MillMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MILL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/mill.example.com/users/Admin@mill.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051  

  elif [ $USING_ORG -eq 6 ]; then
    export CORE_PEER_LOCALMSPID="WholesellerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_WHOLESELLER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/wholeseller.example.com/users/Admin@wholeseller.example.com/msp
    export CORE_PEER_ADDRESS=localhost:12051   

  else
    errorln "ORG Unknown"
  fi
  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_ADDRESS=farmer.example.com:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_ADDRESS=mill.example.com:9051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_ADDRESS=wholeseller.example.com:11051    
  elif [ $USING_ORG -eq 4 ]; then 
    export CORE_PEER_ADDRESS=f1.farmer.example.com:8051
  elif [ $USING_ORG -eq 5 ]; then   
    export CORE_PEER_ADDRESS=m1.mill.example.com:10051
  elif [ $USING_ORG -eq 6 ]; then
    export CORE_PEER_ADDRESS=w1.wholeseller.example.com:12051  
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
    local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  PEER_CONN_PARMS=()
  PEERS=""
  local PEER=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
   PEER= farmer
  elif [ $USING_ORG -eq 2 ]; then
   PEER= mill
  elif [ $USING_ORG -eq 3 ]; then
   PEER= wholeseller
  elif [ $USING_ORG -eq 4 ]; then
   PEER= f1.farmer
  elif [ $USING_ORG -eq 5 ]; then
   PEER= m1.mill
  elif [ $USING_ORG -eq 6 ]; then
   PEER= w1.wholeseller
  fi
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=""
  infoln "Set path to TLS certificate ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
  CA=PEER0_FARMER_CA
  elif [ $USING_ORG -eq 2 ]; then
   CA=PEER0_MILL_CA
  elif [ $USING_ORG -eq 3 ]; then
  CA=PEER0_WHOLESELLER_CA
  elif [ $USING_ORG -eq 4 ]; then
   CA=PEER0_FARMER_CA
  elif [ $USING_ORG -eq 5 ]; then
    CA=PEER0_MILL_CA
  elif [ $USING_ORG -eq 6 ]; then
     CA=PEER0_WHOLESELLER_CA
  fi
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
