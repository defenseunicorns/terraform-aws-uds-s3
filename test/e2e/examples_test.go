package test_test

import (
	"encoding/json"
	"fmt"
	"net/url"
	"testing"

	a "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const expectedBucketPrefix = "terratest-bucket-"
const bucketNamePrefixVar = "name_prefix"
const bucketNameOutput = "bucket_id"

const oidcProviderVar = "eks_oidc_provider_arn"
const awsRegionVar = "region"

const expectedRoleName = "terratest-irsa-role"
const roleNameVar = "irsa_iam_role_name"

const testDir = "../../examples/complete"

// These structs are used to decode the IAM Role Policy Document from JSON.
type PolicyDocument struct {
	Version   string                    `json:"version"`
	Statement []PolicyDocumentStatement `json:"statement"`
}

type PolicyDocumentStatement struct {
	Sid       string                           `json:"sid"`
	Effect    string                           `json:"effect"`
	Principal PolicyDocumentStatementPrincipal `json:"principal"`
	Action    string                           `json:"action"`
	Condition string                           `json:"condition"`
}

type PolicyDocumentStatementPrincipal struct {
	Federated string `json:"federated"`
}

func TestExampleComplete(t *testing.T) {
	t.Parallel()

	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	expectedOidcProviderArn := fmt.Sprintf("arn:aws:iam::111111111111:oidc-provider/oidc.eks.%s.amazonaws.com/id/22222222222222222222222222222222", awsRegion)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testDir,

		Vars: map[string]interface{}{
			bucketNamePrefixVar: expectedBucketPrefix,
			oidcProviderVar:     expectedOidcProviderArn,
			awsRegionVar:        awsRegion,
			roleNameVar:         expectedRoleName,
		},

		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Verify bucket name
	actualBucketName := terraform.Output(t, terraformOptions, bucketNameOutput)
	assert.Contains(t, actualBucketName, expectedBucketPrefix)

	// Verify OIDC ARN of the Role
	iamClient := aws.NewIamClient(t, awsRegion)
	expectedRoleNameCopy := expectedRoleName // because we can't address a constant
	// 1. Get IRSA Role
	iamRoleOutput, err := iamClient.GetRole(&iam.GetRoleInput{
		RoleName: &expectedRoleNameCopy,
	})
	assert.Nil(t, err)

	// 2. Extract and decode assume role policy document
	policyDoc := a.StringValue(iamRoleOutput.Role.AssumeRolePolicyDocument)
	decodedPolicyDoc, _ := url.PathUnescape(policyDoc)

	var policyStruct PolicyDocument
	_ = json.Unmarshal([]byte(decodedPolicyDoc), &policyStruct)

	// 3. Pull out OIDC ARN using the structs at the top and assert
	actualOidcProviderArn := policyStruct.Statement[0].Principal.Federated
	assert.Equal(t, actualOidcProviderArn, expectedOidcProviderArn)
}
