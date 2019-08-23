package handler
// To run: 
// go test -v quotes/handler
import (
    "fmt"
    "testing"
)

func TestGetMySqlEndpoint(t *testing.T) {
	t.Log("testing SSM getMySqlEndpoint...")
	ret := getMySqlEndpoint()
    if ret == "" {
        t.Error("Expected non-null endpoint")
    }
    t.Log("sql endpoint: " + ret)
}

func TestSecrets(t *testing.T) {
	t.Log("testing secrets manager get creds...")
	username, password, _ := getMySqlCredentials()
    if username != "root" {
        t.Error("Expected root username")
    }
    if password == "" {
        t.Error("Expected non-null password")
    }
}

func TestDB(t *testing.T) {
    t.Log("testing init ...")
    Init()
    count := queryQuoteCount()
    if count == 1 {
        t.Error(fmt.Sprintf("count is incorrect: %d", count))
    }
    t.Logf("count: %d", count)
    quote := randomQuote()
    t.Logf("quote: %+v", quote)
}

