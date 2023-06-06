package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const bucketNamePrefixVar = "name_prefix"
const oidcProviderVar = "eks_oidc_provider_arn"
const bucketNameOutput = "bucket_id"

const testDir = "../examples/complete"

func TestExampleComplete(t *testing.T) {
	t.Parallel()

	expectedBucketPrefix := "udss3tst-"
	expectedOidcProviderArn := "arn:aws:iam::111111111111:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/22222222222222222222222222222222"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testDir,

		Vars: map[string]interface{}{
			bucketNamePrefixVar: expectedBucketPrefix,
			oidcProviderVar:     expectedOidcProviderArn,
		},

		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	actualBucketName := terraform.Output(t, terraformOptions, bucketNameOutput)

	assert.Contains(t, actualBucketName, expectedBucketPrefix)
}
