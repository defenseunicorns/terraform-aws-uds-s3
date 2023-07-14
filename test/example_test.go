package test_test

import (
	"testing"

	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

const (
	expectedBucketPrefix  = "uds-s3-test"
	bucketNamePrefixVar   = "name_prefix"
	bucketNameOutput      = "bucket_name"
	createBucketLifecycle = "create_bucket_lifecycle"
	testDir               = "../examples/complete"
	region                = "us-west-2"
)

func TestS3Module(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{TerraformDir: testDir})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify bucket exists and the name is what we expect it to be
	actualBucketName := terraform.Output(t, terraformOptions, bucketNameOutput)
	aws.AssertS3BucketExists(t, region, actualBucketName)
	require.Contains(t, actualBucketName, expectedBucketPrefix)
}

func TestS3ModuleWithLifeCycleRule(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testDir,
		Vars: map[string]interface{}{
			createBucketLifecycle: true,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify bucket exists and the name is what we expect it to be
	actualBucketName := terraform.Output(t, terraformOptions, bucketNameOutput)
	aws.AssertS3BucketExists(t, region, actualBucketName)
	require.Contains(t, actualBucketName, expectedBucketPrefix)

	// Verify lifecycle rule
	expectedStorageClass := "GLACIER"
	s3Client := aws.NewS3Client(t, region)
	input := &s3.GetBucketLifecycleConfigurationInput{
		Bucket: &actualBucketName,
	}
	result, err := s3Client.GetBucketLifecycleConfiguration(input)
	require.Equal(t, result.Rules[0].Transitions[0].StorageClass, &expectedStorageClass)
	require.NoError(t, err)
}
