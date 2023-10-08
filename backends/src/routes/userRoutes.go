package routes

import (
	"crud_go/src/controllers"
	// "github.com/gofiber/fiber/v2"
    "github.com/gin-gonic/gin"
)

func setupRoutes(r *gin.Context) {
   r.POST("/user", controllers.CreateUser)
   app.GET("/user/:id", controllers.ReadUser)
   app.GET("/user", controllers.ReadUsers)
   // app.PUT("/user/:id", controllers.UpdateUser)
   // app.DELETE("/user/:id", controllers.DeleteUser)
}