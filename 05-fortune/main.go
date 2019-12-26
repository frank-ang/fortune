package main

import (
	"fmt"
	"log"
	"os"
	"net/http"
	"github.com/gorilla/mux"
	"github.com/gorilla/handlers"
	"fortune/handler"
)

func main() {
	port := os.Getenv("PORT");
	if port == "" {
		port = "80"
	}
	r := mux.NewRouter()
	r.HandleFunc("/fortune", handler.GetFortune)
	r.HandleFunc("/", Greeting)
	r.HandleFunc("/health", Greeting)
	http.Handle("/", r)
	fmt.Println("Starting up on " + port)
	log.Fatal(http.ListenAndServe(":" + port, handlers.CORS()(r)))
	fmt.Println("Exiting.")
}

func Greeting(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintln(w, "Hello, Fortune!")
}
