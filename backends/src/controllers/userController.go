package controllers

import (
	"crud_go/database"
	"crud_go/src/models"
	"errors"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

func CreateUser(c *gin.Context) {
	var user *models.User
	err := c.ShouldBind(&user)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err,
		})
		return
	}
	fmt.Println("user", user)
	res := database.DB.Create(user)
	fmt.Println("ff", res)
	if res.RowsAffected == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "error createing a user"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"user": user,
	})
	return
}

func ReadUser(c *gin.Context) {
	fmt.Println("1111111")
	var user *models.User
	fmt.Println("user", user)
	id := c.Param("id")
	res := database.DB.Find(&user, id)
	fmt.Println("res", res)
	if res.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{
			"message": "User not found",
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"user": user,
	})
	return
}

func ReadUsers(c *gin.Context) {
	var users []*models.User
	res := database.DB.Find(&users)
	if res.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": errors.New("authors not found"),
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"users": users,
	})
	return
}

func UpdateUser(c *gin.Context) {
  var user *models.User
   id := c.Param("id")
   err := c.ShouldBind(&user)

   if err != nil {
       c.JSON(http.StatusBadRequest, gin.H{
           "error": err,
       })
       return
   }

   var updateUser *models.User
   res := database.DB.Model(&updateUser).Where("id = ?", id).Updates(user)

   if res.RowsAffected == 0 {
       c.JSON(http.StatusBadRequest, gin.H{
           "error": "user not updated",
       })
       return
   }
   c.JSON(http.StatusOK, gin.H{
       "user": user,
   })
   return
}

func DeleteUser(c *gin.Context) {
  var user *models.User
   id := c.Param("id")
   res := database.DB.Find(&user, id)
   if res.RowsAffected == 0 {
       c.JSON(http.StatusNotFound, gin.H{
           "message": "user not found",
       })
       return
   }
   database.DB.Delete(&user)
   c.JSON(http.StatusOK, gin.H{
       "message": "User deleted successfully",
   })
   return
}
