package test_test

import (
	"encoding/json"
	"fmt"
	"net/url"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/aws/aws-sdk-go/service/s3"
	terratest_aws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	awsRegion            = "us-west-2"
	bucketNameOutput     = "bucket_id"
	expectedBucketPrefix = "ex-complete"
	modulePath           = "../examples/complete"
)

type policyDocumentStatementPrincipal struct {
	Federated string `json:"Federated"`
}

type policyDocumentStatementCondition struct {
	StringEquals map[string]interface{} `json:"StringEquals"`
}

type policyDocumentStatement struct {
	Sid       string                           `json:"Sid"`
	Effect    string                           `json:"Effect"`
	Principal policyDocumentStatementPrincipal `json:"Principal"`
	Action    string                           `json:"Action"`
	Condition policyDocumentStatementCondition `json:"Condition"`
}

type policyDocument struct {
	Version   string                    `json:"Version"`
	Statement []policyDocumentStatement `json:"Statement"`
}

func TestExampleComplete(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: modulePath,
		VarFiles:     []string{"example_complete.tfvars"},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Verify bucket name
	actualBucketName := terraform.Output(t, terraformOptions, bucketNameOutput)
	assert.Contains(t, actualBucketName, expectedBucketPrefix)

	// Verify OIDC ARN of the Role
	iamClient := terratest_aws.NewIamClient(t, awsRegion)
	expectedRoleName := "ex-complete-irsa-role"
	iamRoleOutput, err := iamClient.GetRole(&iam.GetRoleInput{
		RoleName: &expectedRoleName,
	})
	require.NoError(t, err)

	// 2. Extract and decode assume role policy document
	policyDoc := aws.StringValue(iamRoleOutput.Role.AssumeRolePolicyDocument)
	decodedPolicyDoc, _ := url.PathUnescape(policyDoc)

	var policyStruct policyDocument
	err = json.Unmarshal([]byte(decodedPolicyDoc), &policyStruct)
	require.NoError(t, err)

	// 3. Pull out OIDC ARN using the structs at the top and assert
	expectedOidcProviderArn := fmt.Sprintf("arn:aws:iam::111111111111:oidc-provider/oidc.eks.%s.amazonaws.com/id/22222222222222222222222222222222", awsRegion)
	actualOidcProviderArn := policyStruct.Statement[0].Principal.Federated
	assert.Equal(t, expectedOidcProviderArn, actualOidcProviderArn)

	// Verify lifecycle rule
	expectedStorageClass := "GLACIER"
	s3Client := terratest_aws.NewS3Client(t, awsRegion)
	input := &s3.GetBucketLifecycleConfigurationInput{
		Bucket: &actualBucketName,
	}
	result, err := s3Client.GetBucketLifecycleConfiguration(input)
	require.NoError(t, err)
	assert.Equal(t, &expectedStorageClass, result.Rules[0].Transitions[0].StorageClass)
}

func TestS3WithNoIRSA(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: modulePath,
		VarFiles:     []string{"example_complete.tfvars"},
		Vars: map[string]interface{}{
			"create_irsa": false,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Verify bucket name
	actualBucketName := terraform.Output(t, terraformOptions, bucketNameOutput)
	assert.Contains(t, actualBucketName, expectedBucketPrefix)

	// Verify IRSA role was not created via the S3 module when create_irsa is set to false
	iamClient := terratest_aws.NewIamClient(t, awsRegion)
	shouldBeEmpty, err := iamClient.GetRole(&iam.GetRoleInput{
		RoleName: aws.String("ex-complete-irsa-role"),
	})
	require.Error(t, err)
	assert.ErrorContains(t, err, "NoSuchEntity")
	assert.Empty(t, shouldBeEmpty)

	// Verify the S3 bucket policy gets created when create_irsa is set to false
	terratest_aws.AssertS3BucketPolicyExists(t, awsRegion, actualBucketName)
}
