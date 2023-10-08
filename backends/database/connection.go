package database

import(
	"fmt"
	"os"
	"gorm.io/gorm"
	"gorm.io/driver/postgres"
	)
var DB *gorm.DB

func Connect(){
	    var err error
	//dialect := os.Getenv("DIALECT")
	host := os.Getenv("HOST")
	port := os.Getenv("PORT")
	user := os.Getenv("USER")
	dbname := os.Getenv("DBNAME")
	password := os.Getenv("PASSWORD")

    dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",host,port,user,password,dbname)
    DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})

    if err != nil {
        panic(err)
    } else {
        fmt.Println("Successfully connected to the database")
    }
// // defer connect.Close()
}