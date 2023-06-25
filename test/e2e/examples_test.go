package test_test

import (
	// "encoding/json"
	// "fmt"
	"testing"
	"strings"
	"time"

	// a "github.com/aws/aws-sdk-go/aws"
	// "github.com/aws/aws-sdk-go/service/iam"
	// "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	teststructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// const expectedBucketPrefix = "terratest-bucket-"
// const bucketNamePrefixVar = "name_prefix"
// const bucketNameOutput = "bucket_id"
// 
// const oidcProviderVar = "eks_oidc_provider_arn"
// const awsRegionVar = "region"
// const createIrsaVar = "create_irsa"
// 
// const expectedRoleName = "terratest-irsa-role"
// const roleNameVar = "irsa_iam_role_name"
// 
// const testDir = "../../examples/complete"
// 
// // These structs are used to decode the IAM Role Policy Document from JSON.
// type PolicyDocument struct {
// 	Version   string                    `json:"version"`
// 	Statement []PolicyDocumentStatement `json:"statement"`
// }
// 
// type PolicyDocumentStatement struct {
// 	Sid       string                           `json:"sid"`
// 	Effect    string                           `json:"effect"`
// 	Principal PolicyDocumentStatementPrincipal `json:"principal"`
// 	Action    string                           `json:"action"`
// 	Condition string                           `json:"condition"`
// }
// 
// type PolicyDocumentStatementPrincipal struct {
// 	Federated string `json:"federated"`
// }

func TestExampleCompleteNoIrsa(t *testing.T) {
	t.Parallel()
	tempFolder := teststructure.CopyTerraformFolderToTemp(t, "../..", "examples/complete")
	terraformOptions := &terraform.Options{
		TerraformDir: tempFolder,
		Upgrade:      true,
		VarFiles:     []string{"example_complete.tfvars"},
		Vars: map[string]interface{}{
			// Creating the backend.tf file would create issues with the test pipeline, since Terraform will throw an error saying "Backend initialization required, please run "terraform init". To avoid that, we'll skip the creation of the backend.tf file.
			// "create_backend_file": false,
		},
		RetryableTerraformErrors: map[string]string{
			".*empty output.*": "bug in aws_s3_bucket_logging, intermittent error",
		},
		MaxRetries:         5,
		TimeBetweenRetries: 5 * time.Second,
	}

	// Defer the teardown
	defer func() {
		t.Helper()
		teststructure.RunTestStage(t, "TEARDOWN", func() {
			terraform.Destroy(t, terraformOptions)
		})
	}()

	// Set up the infra
	teststructure.RunTestStage(t, "SETUP", func() {
		terraform.InitAndApply(t, terraformOptions)
	})

	// Run assertions
	teststructure.RunTestStage(t, "TEST", func() {
		bucketId := terraform.Output(t, terraformOptions, "bucket_id")
		expectedBucketIDStartsWith := "ex-complete"
		assert.Equal(t, true, strings.HasPrefix(bucketId, expectedBucketIDStartsWith))
	})
}


