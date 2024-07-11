package common

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/applicationautoscaling"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/require"
)

func TestAutoscalingTarget(t *testing.T, ctx types.TestContext) {
	appAutoscalingClient := applicationautoscaling.NewFromConfig(GetAWSConfig(t))
	//serviceId := terraform.Output(t, ctx.TerratestTerraformOptions(), "service_id")

	output, err := appAutoscalingClient.DescribeScalableTargets(context.TODO(), &applicationautoscaling.DescribeScalableTargetsInput{
		ServiceNamespace: "ecs",
		//ResourceIds:      []string{serviceId},
	})
	if err != nil {
		t.Errorf("Unable to describe scalable targets, %v", err)
	}
	//autoscalingTarget := output.ScalableTargets[0]

	t.Run("TestTargetExists", func(t *testing.T) {
		require.NotEmpty(t, output.ScalableTargets, "No scalable targets found")
	})

}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
