package main

import (
	"fmt"
	"log"
	"os"
	"net/http"
	"github.com/gorilla/mux"
	"quotes/handler"
)

func main() {
	port := os.Getenv("PORT");
	if port == "" {
		port = "80"
	}

	r := mux.NewRouter()
	r.HandleFunc("/quote", handler.GetQuote)
	r.HandleFunc("/", HealthCheck)
	r.HandleFunc("/health", HealthCheck)
	http.Handle("/", r)
	fmt.Println("Starting up on " + port)
	log.Fatal(http.ListenAndServe(":" + port, nil))
	fmt.Println("Exiting.")
}

func HealthCheck(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintln(w, "Hello, World!")
}
