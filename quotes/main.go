package main

import (
	"fmt"
	"log"
	"os"
	"net/http"
	"github.com/gorilla/mux"
	"quotes/handler"
	//"github.com/aws/aws-sdk-go/aws/session"
	//// "github.com/aws/aws-sdk-go/aws/credentials"
	//// "github.com/aws/aws-sdk-go/aws/credentials/stscreds"
	////  "github.com/aws/aws-sdk-go/service/s3"
)

func main() {
	port := os.Getenv("PORT");
	if port == "" {
		port = "8080"
	}

	r := mux.NewRouter()
	r.HandleFunc("/", handler.GetQuote)
	r.HandleFunc("/debug", debug)

	http.Handle("/", r)
	fmt.Println("Starting up on " + port)
	log.Fatal(http.ListenAndServe(":" + port, nil))
}

func debug(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintln(w, "Debug handler!")
	//sess := session.Must(session.NewSession())
	//fmt.Fprintf(w, "AWS session: %s", sess)
}
