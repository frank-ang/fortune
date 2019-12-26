#!/bin/bash
export P_CANARY_ITERATIONS=${CANARY_ITERATIONS:-1}
export P_TEST_ITERATIONS=${TEST_ITERATIONS:-3}
export P_DELAY_REQUEST_MS=${DELAY_REQUEST_MS:-1000}
export P_METRIC_NAMESPACE=${METRIC_NAMESPACE:-fortune-canary}

echo "starting test iterations. total iterations: $P_CANARY_ITERATIONS"

for (( i=1; i<=$P_CANARY_ITERATIONS; i++ ))
do

	echo "Canary iteration $i : calling newman tests with P_TEST_ITERATIONS=$P_TEST_ITERATIONS and P_DELAY_REQUEST_MS=$P_DELAY_REQUEST_MS"
	newman run ./fortune-tests.postman_collection.json \
		--env-var API_ENDPOINT=$API_ENDPOINT \
		--delay-request $P_DELAY_REQUEST_MS \
		--iteration-count $P_TEST_ITERATIONS \
		--reporters junit
	RESULT_FILE=`ls -tr newman/*xml | tail -1`
	echo "Completed tests. Parsing test results in result file: $RESULT_FILE"

	# response time...
	RESPONSE_TIME=`xmllint --xpath "string(//testsuites/testsuite[1]/@time)" $RESULT_FILE`
	# errors ...
	ERROR_COUNT=`xmllint --xpath "string(//testsuites/testsuite[1]/@errors)" $RESULT_FILE`
	# failures ...
	FAILURE_COUNT=`xmllint --xpath "string(//testsuites/testsuite[1]/@failures)" $RESULT_FILE`

	# tests ...
	TEST_COUNT=`xmllint --xpath "string(//testsuites/@tests)" $RESULT_FILE`

	echo "Publishing cloudwatch metrics. $P_METRIC_NAMESPACE response-time = $RESPONSE_TIME"

	# put metric
	aws cloudwatch put-metric-data --namespace $P_METRIC_NAMESPACE \
	--metric-name response-time --unit Seconds \
	--value $RESPONSE_TIME 

	aws cloudwatch put-metric-data --namespace $P_METRIC_NAMESPACE \
	--metric-name test-count --unit Count \
	--value $TEST_COUNT 

	aws cloudwatch put-metric-data --namespace $P_METRIC_NAMESPACE \
	--metric-name error-count --unit Count \
	--value $ERROR_COUNT 

	aws cloudwatch put-metric-data --namespace $P_METRIC_NAMESPACE \
	--metric-name failure-count --unit Count \
	--value $FAILURE_COUNT 

	echo "Canary iteration ${i} completed."

	sleep $((P_DELAY_REQUEST_MS/1000))

done

echo "All $P_CANARY_ITERATIONS Canary iterations completed."

