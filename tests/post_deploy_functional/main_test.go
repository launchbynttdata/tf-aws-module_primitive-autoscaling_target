package test

import (
	"testing"

	"github.com/launchbynttdata/lcaf-component-terratest/lib"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	testimpl "github.com/launchbynttdata/tf-aws-module_primitive-autoscaling_target/tests/testimpl"
)

const (
	testConfigsExamplesFolderDefault = "../../examples"
	infraTFVarFileNameDefault        = "test.tfvars"
)

func TestAutoscalingTargetModule(t *testing.T) {
	// The terraform provider ignores the aws cloud map attributes, but notices when AWS changes them from null to empty map
	// This is why the terraform apply is not idempotent, though the second apply will not change anything
	ctx := types.CreateTestContextBuilder().
		SetTestConfig(&testimpl.ThisTFModuleConfig{}).
		SetTestConfigFolderName(testConfigsExamplesFolderDefault).
		SetTestConfigFileName(infraTFVarFileNameDefault).
		Build()

	lib.RunSetupTestTeardown(t, *ctx, testimpl.TestAutoscalingTarget)
}
