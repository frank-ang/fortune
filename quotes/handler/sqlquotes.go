package handler
import (
	"fmt"
	"net/http"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/ssm"

	//// "github.com/aws/aws-sdk-go/aws/credentials"
	//// "github.com/aws/aws-sdk-go/aws/credentials/stscreds"
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