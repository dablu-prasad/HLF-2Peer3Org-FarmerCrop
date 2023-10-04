package main

import (
	"fmt"
	"rest-api-go/web"
)

func main() {
	//Initialize setup for Org1
	cryptoPath := "../../network/organizations/peerOrganizations/farmer.example.com"
	orgConfig := web.OrgSetup{
		OrgName:      "FarmerMSP",
		MSPID:        "FarmerMSP",
		CertPath:     cryptoPath + "/users/User1@farmer.example.com/msp/signcerts/cert.pem",
		KeyPath:      cryptoPath + "/users/User1@farmer.example.com/msp/keystore/",
		TLSCertPath:  cryptoPath + "/peers/farmer.example.com/tls/ca.crt",
		PeerEndpoint: "localhost:7051",
		GatewayPeer:  "farmer.example.com",
	}

	orgSetup, err := web.Initialize(orgConfig)
	if err != nil {
		fmt.Println("Error initializing setup for Org1: ", err)
	}
	web.Serve(web.OrgSetup(*orgSetup))
}
