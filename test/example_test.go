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
	awsRegionVar          = "region"
)

var approvedRegions = []string{"us-east-1", "us-east-2", "us-west-1", "us-west-2"}

func TestS3Module(t *testing.T) {
	awsRegion := aws.GetRandomStableRegion(t, approvedRegions, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testDir,
		Vars: map[string]interface{}{
			awsRegionVar: awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify bucket exists and the name is what we expect it to be
	actualBucketName := terraform.Output(t, terraformOptions, bucketNameOutput)
	aws.AssertS3BucketExists(t, awsRegion, actualBucketName)
	require.Contains(t, actualBucketName, expectedBucketPrefix)
}

func TestS3ModuleWithLifeCycleRule(t *testing.T) {
	awsRegion := aws.GetRandomStableRegion(t, approvedRegions, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testDir,
		Vars: map[string]interface{}{
			awsRegionVar:          awsRegion,
			createBucketLifecycle: true,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify bucket exists and the name is what we expect it to be
	actualBucketName := terraform.Output(t, terraformOptions, bucketNameOutput)
	aws.AssertS3BucketExists(t, awsRegion, actualBucketName)
	require.Contains(t, actualBucketName, expectedBucketPrefix)

	// Verify lifecycle rule
	expectedStorageClass := "GLACIER"
	s3Client := aws.NewS3Client(t, awsRegion)
	input := &s3.GetBucketLifecycleConfigurationInput{
		Bucket: &actualBucketName,
	}
	result, err := s3Client.GetBucketLifecycleConfiguration(input)
	require.Equal(t, result.Rules[0].Transitions[0].StorageClass, &expectedStorageClass)
	require.NoError(t, err)
}
