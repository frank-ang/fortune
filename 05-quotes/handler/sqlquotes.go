package handler
import (
	"fmt"
	"log"
	"net/http"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/ssm"
	"database/sql"
)

func GetQuote(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintln(w, "Get Quote handler!")
}

func getMySqlCredentials() (string, string) {
	return "root", "TODO"
}

// Get the MySQL endpoint from Systems Manager Parameter Store
func getMySqlEndpoint() string {
	sess := session.Must(session.NewSession())
	ssmSvc := ssm.New(sess)
	parameterName := "playground-database-endpoint"
	input := &ssm.GetParameterInput{ Name: &parameterName }
	result, err := ssmSvc.GetParameter(input)
	if err != nil {
	    if aerr, ok := err.(awserr.Error); ok {
	        switch aerr.Code() {
	        default:
	            fmt.Println(aerr.Error())
	        }
	    } else {
	        fmt.Println(err.Error())
	    }
		return ""
	}
	retval := *(result.Parameter.Value)
	//fmt.Println(retval)
	return retval
}

func initConfiguration() {
	username, password := getMySqlCredentials()
	endpoint := getMySqlEndpoint()
	initConnectionPool(username, password, endpoint)
}

func initConnectionPool(username string, password string, endpoint string) {
    connectionString := fmt.Sprintf("%s:%s@tcp(%s:3306)/demo", username, password, endpoint)
	db, err := sql.Open("mysql", connectionString)
		//"root:TODOpassword@tcp(127.0.0.1:3306)/demo")
	if err != nil {
		log.Fatal(err)
	}
	db.SetMaxIdleConns(5)
	defer db.Close()
}

// S3 example
func getS3Buckets() string {
	sess := session.Must(session.NewSession())
	s3svc := s3.New(sess)
	input := &s3.ListBucketsInput{}
	result, err := s3svc.ListBuckets(input)
	if err != nil {
	    if aerr, ok := err.(awserr.Error); ok {
	        switch aerr.Code() {
	        default:
	            fmt.Println(aerr.Error())
	        }
	    } else {
	        fmt.Println(err.Error())
	    }
		return ""
	}
	fmt.Println(result)
	return "Dummy result"
}