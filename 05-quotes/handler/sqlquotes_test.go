package handler
// To run: 
// go test -v quotes/handler
import (
    "fmt"
    "testing"
)

func SkipTestS3(t *testing.T) {
	t.Log("testing s3 ...")
	ret := getS3Buckets()
    if ret == "" {
        t.Error("Expected non-null s3")
    }
}

func TestSsm(t *testing.T) {
	t.Log("testing ssm...")
	ret := getMySqlEndpoint()
    if ret == "" {
        t.Error("Expected non-null endpoint")
    }
    fmt.Println("sql endpoint: " + ret)
}

func TestSecrets(t *testing.T) {
	t.Log("testing secrets manager...")
	username, password, _ := getMySqlCredentials()
    if username != "root" {
        t.Error("Expected root username")
    }
    if password == "" {
        t.Error("Expected non-null password")
    }
    fmt.Sprintf("username: %s, password (REMOVE ME!): %s", username, password)
}