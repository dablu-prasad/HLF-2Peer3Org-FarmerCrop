go mod init crud_go

go get github.com/jinzhu/gorm

go run main.go


packages
---------------
go get -u github.com/gin-gonic/gin

go get -u gorm.io/driver/postgres

go get github.com/gorilla/mux github.com/lib/pq


format structure
--------------------------

https://www.twilio.com/blog/build-restful-api-using-golang-and-gin

install go
-----------------
link:- https://tecadmin.net/how-to-install-go-on-ubuntu-20-04/



sudo apt-get update  
sudo apt-get -y upgrade 
wget  https://go.dev/dl/go1.20.5.linux-amd64.tar.gz 

sudo tar -xvf go1.20.2.linux-amd64.tar.gz
sudo mv go /usr/local
export GOROOT=/usr/local/go
export GOPATH=$HOME/Projects/Proj1 
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH 
go version



go mod download
go mod vendor

missing go.sum entry for module providing package github.com/hyperledger/fabric-protos-go-apiv2/common (imported by github.com/hyperledger/fabric-gateway/pkg/client); to add:

go mod tidy -e

