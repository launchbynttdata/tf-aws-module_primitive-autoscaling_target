package common

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/applicationautoscaling"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestAutoscalingTarget(t *testing.T, ctx types.TestContext) {
	appAutoscalingClient := applicationautoscaling.NewFromConfig(GetAWSConfig(t))
	targetId := terraform.Output(t, ctx.TerratestTerraformOptions(), "autoscaling_target_id")

	output, err := appAutoscalingClient.DescribeScalableTargets(context.TODO(), &applicationautoscaling.DescribeScalableTargetsInput{
		ServiceNamespace: "ecs",
		ResourceIds:      []string{targetId},
	})
	if err != nil {
		t.Errorf("Unable to describe scalable targets, %v", err)
	}

	t.Run("TestOnlyOneTargetExists", func(t *testing.T) {
		assert.Len(t, output.ScalableTargets, 1, "Expected one scalable target, got %d", len(output.ScalableTargets))
	})

	autoscalingTarget := output.ScalableTargets[0]

	t.Run("TestTargetHasCorrectResourceID", func(t *testing.T) {
		require.Equal(t, targetId, *autoscalingTarget.ResourceId, "Expected resource ID to be %s, got %s", targetId, *autoscalingTarget.ResourceId)
	})
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
