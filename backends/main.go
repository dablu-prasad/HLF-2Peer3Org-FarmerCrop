package main

import (
	"fmt"
	"net/http"
	"backend/src/models"
)

func main() {
	//Initialize setup for Org1
	cryptoPath := "../fabricNetwork/network/organizations/peerOrganizations/farmer.example.com"
	orgConfig := models.OrgSetup{
		OrgName:      "FarmerMSP",
		MSPID:        "FarmerMSP",
		CertPath:     cryptoPath + "/users/User1@farmer.example.com/msp/signcerts/cert.pem",
		KeyPath:      cryptoPath + "/users/User1@farmer.example.com/msp/keystore/",
		TLSCertPath:  cryptoPath + "/peers/farmer.example.com/tls/ca.crt",
		PeerEndpoint: "localhost:7051",
		GatewayPeer:  "farmer.example.com",
	}
	orgSetup, err := models.Initialize(orgConfig)
	if err != nil {
		fmt.Println("Error initializing setup for Org1: ", err)
	}
	Serve(models.OrgSetup(*orgSetup))
}

// Serve starts http web server.
func Serve(setups models.OrgSetup) {
	http.HandleFunc("/query", setups.Query)
	http.HandleFunc("/invoke", setups.Invoke)
	fmt.Println("Listening (http://localhost:3000/)...")
	if err := http.ListenAndServe(":3000", nil); err != nil {
		fmt.Println(err)
	}
}
