#!/bin/bash

function createFarmer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/farmer.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/farmer.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-farmer --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-farmer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-farmer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-farmer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-farmer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/farmer.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy farmer's CA cert to farmer's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/farmer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/farmer.example.com/msp/tlscacerts/ca.crt"

  # Copy farmer's CA cert to farmer's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/farmer.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/farmer.example.com/tlsca/tlsca.farmer.example.com-cert.pem"

  # Copy farmer's CA cert to farmer's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/farmer.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/farmer.example.com/ca/ca.farmer.example.com-cert.pem"

  infoln "Registering farmer"
  set -x
  fabric-ca-client register --caname ca-farmer --id.name farmer --id.secret farmerpw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering f1-farmer"
  set -x
  fabric-ca-client register --caname ca-farmer --id.name f1farmer --id.secret f1farmerpw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-farmer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  fabric-ca-client register --caname ca-farmer --id.name user2 --id.secret user2pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-farmer --id.name farmeradmin --id.secret farmeradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the farmer msp"
  set -x
  fabric-ca-client enroll -u https://farmer:farmerpw@localhost:7054 --caname ca-farmer -M "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/farmer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the farmer msp"
  set -x
  fabric-ca-client enroll -u https://f1farmer:f1farmerpw@localhost:7054 --caname ca-farmer -M "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/f1.farmer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/farmer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/farmer.example.com/msp/config.yaml"
  cp "${PWD}/organizations/peerOrganizations/farmer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/f1.farmer.example.com/msp/config.yaml"

  infoln "Generating the farmer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://farmer:farmerpw@localhost:7054 --caname ca-farmer -M "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/farmer.example.com/tls" --enrollment.profile tls --csr.hosts farmer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the farmer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://f1farmer:f1farmerpw@localhost:7054 --caname ca-farmer -M "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/f1.farmer.example.com/tls" --enrollment.profile tls --csr.hosts f1.farmer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  { set +x; } 2>/dev/null


  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer0's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/farmer.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/farmer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/farmer.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/farmer.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/farmer.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/farmer.example.com/tls/server.key"

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer1's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/f1.farmer.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/f1.farmer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/f1.farmer.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/f1.farmer.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/f1.farmer.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/farmer.example.com/peers/f1.farmer.example.com/tls/server.key"


  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-farmer -M "${PWD}/organizations/peerOrganizations/farmer.example.com/users/User1@farmer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  fabric-ca-client enroll -u https://user2:user2pw@localhost:7054 --caname ca-farmer -M "${PWD}/organizations/peerOrganizations/farmer.example.com/users/User2@farmer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/farmer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/farmer.example.com/users/User1@farmer.example.com/msp/config.yaml"
  cp "${PWD}/organizations/peerOrganizations/farmer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/farmer.example.com/users/User2@farmer.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://farmeradmin:farmeradminpw@localhost:7054 --caname ca-farmer -M "${PWD}/organizations/peerOrganizations/farmer.example.com/users/Admin@farmer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/farmer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/farmer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/farmer.example.com/users/Admin@farmer.example.com/msp/config.yaml"
}

function createMill() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/mill.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/mill.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-mill --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-mill.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-mill.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-mill.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-mill.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/mill.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy mill's CA cert to mill's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/mill.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/mill/ca-cert.pem" "${PWD}/organizations/peerOrganizations/mill.example.com/msp/tlscacerts/ca.crt"

  # Copy mill's CA cert to mill's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/mill.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/mill/ca-cert.pem" "${PWD}/organizations/peerOrganizations/mill.example.com/tlsca/tlsca.mill.example.com-cert.pem"

  # Copy mill's CA cert to mill's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/mill.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/mill/ca-cert.pem" "${PWD}/organizations/peerOrganizations/mill.example.com/ca/ca.mill.example.com-cert.pem"

  infoln "Registering mill"
  set -x
  fabric-ca-client register --caname ca-mill --id.name mill --id.secret millpw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering m1-mill"
  set -x
  fabric-ca-client register --caname ca-mill --id.name m1mill --id.secret m1millpw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-mill --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  fabric-ca-client register --caname ca-mill --id.name user2 --id.secret user2pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-mill --id.name milladmin --id.secret milladminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the mill msp"
  set -x
  fabric-ca-client enroll -u https://mill:millpw@localhost:8054 --caname ca-mill -M "${PWD}/organizations/peerOrganizations/mill.example.com/peers/mill.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the m1-mill msp"
  set -x
  fabric-ca-client enroll -u https://m1mill:m1millpw@localhost:8054 --caname ca-mill -M "${PWD}/organizations/peerOrganizations/mill.example.com/peers/m1.mill.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/mill.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/mill.example.com/peers/mill.example.com/msp/config.yaml"
  cp "${PWD}/organizations/peerOrganizations/mill.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/mill.example.com/peers/m1.mill.example.com/msp/config.yaml"

  infoln "Generating the mill-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://mill:millpw@localhost:8054 --caname ca-mill -M "${PWD}/organizations/peerOrganizations/mill.example.com/peers/mill.example.com/tls" --enrollment.profile tls --csr.hosts mill.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the m1mill-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://m1mill:m1millpw@localhost:8054 --caname ca-mill -M "${PWD}/organizations/peerOrganizations/mill.example.com/peers/m1.mill.example.com/tls" --enrollment.profile tls --csr.hosts m1.mill.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/mill.example.com/peers/mill.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/mill.example.com/peers/mill.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/mill.example.com/peers/mill.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/mill.example.com/peers/mill.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/mill.example.com/peers/mill.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/mill.example.com/peers/mill.example.com/tls/server.key"

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer1's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/mill.example.com/peers/m1.mill.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/mill.example.com/peers/m1.mill.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/mill.example.com/peers/m1.mill.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/mill.example.com/peers/m1.mill.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/mill.example.com/peers/m1.mill.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/mill.example.com/peers/m1.mill.example.com/tls/server.key"


  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-mill -M "${PWD}/organizations/peerOrganizations/mill.example.com/users/User1@mill.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  fabric-ca-client enroll -u https://user2:user2pw@localhost:8054 --caname ca-mill -M "${PWD}/organizations/peerOrganizations/mill.example.com/users/User2@mill.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/mill.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/mill.example.com/users/User1@mill.example.com/msp/config.yaml"
  cp "${PWD}/organizations/peerOrganizations/mill.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/mill.example.com/users/User2@mill.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://milladmin:milladminpw@localhost:8054 --caname ca-mill -M "${PWD}/organizations/peerOrganizations/mill.example.com/users/Admin@mill.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/mill/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/mill.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/mill.example.com/users/Admin@mill.example.com/msp/config.yaml"
}

function createWholeseller() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/wholeseller.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/wholeseller.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-wholeseller --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-wholeseller.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-wholeseller.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-wholeseller.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-wholeseller.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/wholeseller.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy wholeseller's CA cert to wholeseller's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/wholeseller.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem" "${PWD}/organizations/peerOrganizations/wholeseller.example.com/msp/tlscacerts/ca.crt"

  # Copy wholeseller's CA cert to wholeseller's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/wholeseller.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem" "${PWD}/organizations/peerOrganizations/wholeseller.example.com/tlsca/tlsca.wholeseller.example.com-cert.pem"

  # Copy wholeseller's CA cert to wholeseller's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/wholeseller.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem" "${PWD}/organizations/peerOrganizations/wholeseller.example.com/ca/ca.wholeseller.example.com-cert.pem"

  infoln "Registering wholeseller"
  set -x
  fabric-ca-client register --caname ca-wholeseller --id.name wholeseller --id.secret wholesellerpw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering w1-wholeseller"
  set -x
  fabric-ca-client register --caname ca-wholeseller --id.name w1wholeseller --id.secret w1wholesellerpw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-wholeseller --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  fabric-ca-client register --caname ca-wholeseller --id.name user2 --id.secret user2pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-wholeseller --id.name wholeselleradmin --id.secret wholeselleradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the wholeseller msp"
  set -x
  fabric-ca-client enroll -u https://wholeseller:wholesellerpw@localhost:9054 --caname ca-wholeseller -M "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/wholeseller.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the w1-wholeseller msp"
  set -x
  fabric-ca-client enroll -u https://w1wholeseller:w1wholesellerpw@localhost:9054 --caname ca-wholeseller -M "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/w1.wholeseller.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/wholeseller.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/wholeseller.example.com/msp/config.yaml"
  cp "${PWD}/organizations/peerOrganizations/wholeseller.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/w1.wholeseller.example.com/msp/config.yaml"

  infoln "Generating the wholeseller-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://wholeseller:wholesellerpw@localhost:9054 --caname ca-wholeseller -M "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/wholeseller.example.com/tls" --enrollment.profile tls --csr.hosts wholeseller.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the w1wholeseller-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://w1wholeseller:w1wholesellerpw@localhost:9054 --caname ca-wholeseller -M "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/w1.wholeseller.example.com/tls" --enrollment.profile tls --csr.hosts w1.wholeseller.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/wholeseller.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/wholeseller.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/wholeseller.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/wholeseller.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/wholeseller.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/wholeseller.example.com/tls/server.key"

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer1's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/w1.wholeseller.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/w1.wholeseller.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/w1.wholeseller.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/w1.wholeseller.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/w1.wholeseller.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/wholeseller.example.com/peers/w1.wholeseller.example.com/tls/server.key"


  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-wholeseller -M "${PWD}/organizations/peerOrganizations/wholeseller.example.com/users/User1@wholeseller.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  fabric-ca-client enroll -u https://user2:user2pw@localhost:9054 --caname ca-wholeseller -M "${PWD}/organizations/peerOrganizations/wholeseller.example.com/users/User2@wholeseller.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/wholeseller.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/wholeseller.example.com/users/User1@wholeseller.example.com/msp/config.yaml"
  cp "${PWD}/organizations/peerOrganizations/wholeseller.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/wholeseller.example.com/users/User2@wholeseller.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://wholeselleradmin:wholeselleradminpw@localhost:9054 --caname ca-wholeseller -M "${PWD}/organizations/peerOrganizations/wholeseller.example.com/users/Admin@wholeseller.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/wholeseller/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/wholeseller.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/wholeseller.example.com/users/Admin@wholeseller.example.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:10054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}