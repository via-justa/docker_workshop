package main

import (
	"net/http"

	"github.com/labstack/echo"
)

func hello(ctx echo.Context) error {
	user := ctx.Param("user")
	return ctx.String(http.StatusOK, "Hello "+user+", isn't docker cool? ;)\n")
}

func main() {
	e := echo.New()

	e.Static("/assets", "/assets")

	e.File("/", "/pages/index.html")

	e.GET("/:user", hello)
	e.Logger.Fatal(e.Start(":8000"))
}
