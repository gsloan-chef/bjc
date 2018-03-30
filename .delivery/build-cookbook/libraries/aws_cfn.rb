require 'aws-sdk'

def get_public_ip(region, stack_name, logical_resource_id)
  return unless Aws::CloudFormation::Stack.new(region: region, name: stack_name).exists?
  ec2 = Aws::EC2::Resource.new(region: region)
  instance_id = get_stack_instance_resource(region, stack_name, logical_resource_id)
  return unless ec2.instance(instance_id).exists?
  ec2.instance(instance_id).public_ip_address
end

def get_stack_instance_resource(region, stack_name, logical_resource_id)
  cfn = Aws::CloudFormation::Client.new(region: region)
  resp = cfn.describe_stack_resource(stack_name: stack_name, logical_resource_id: logical_resource_id)
  resp.stack_resource_detail.physical_resource_id
end
