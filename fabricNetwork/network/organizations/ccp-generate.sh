#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=farmer
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/farmer.example.com/tlsca/tlsca.farmer.example.com-cert.pem
CAPEM=organizations/peerOrganizations/farmer.example.com/ca/ca.farmer.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/farmer.example.com/connection-farmer.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/farmer.example.com/connection-farmer.yaml

ORG=mill
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/mill.example.com/tlsca/tlsca.mill.example.com-cert.pem
CAPEM=organizations/peerOrganizations/mill.example.com/ca/ca.mill.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/mill.example.com/connection-mill.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/mill.example.com/connection-mill.yaml


ORG=wholeseller
P0PORT=11051
CAPORT=9054
PEERPEM=organizations/peerOrganizations/wholeseller.example.com/tlsca/tlsca.wholeseller.example.com-cert.pem
CAPEM=organizations/peerOrganizations/wholeseller.example.com/ca/ca.wholeseller.example.com-cert.pem


echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/wholeseller.example.com/connection-wholeseller.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/wholeseller.example.com/connection-wholeseller.yaml
