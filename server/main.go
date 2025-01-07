package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World!\n")
}

func main() {
	http.HandleFunc("GET /", handler)
	http.ListenAndServe(":8080", nil)
}
