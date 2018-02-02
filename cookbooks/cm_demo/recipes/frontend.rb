# Only check the frontend if this recipe is in use
node.override['audit']['profiles'] = [
  {
    name: 'Linux Baseline',
    compliance: 'workstation-1/cm_frontend',
  },
]

# Nothing up my sleeves
node.override['bjc-ecommerce']['company-name'] = "Planet Express (With a scalable frontend)"

# Update DB Attributes based on a qurey of the Chef Server
dbquery = "chef_environment:#{node.chef_environment}" \
          ' AND recipes:bjc-ecommerce\:\:mysql'

dbhost = search(:node, dbquery).first
if dbhost
  node.override['bjc-ecommerce']['db-host'] = dbhost['ec2']['public_ipv4']
else
  node.override['bjc-ecommerce']['db-host'] = 'localhost'
end

include_recipe 'bjc-ecommerce::tksetup'
include_recipe 'bjc-ecommerce::java'
include_recipe 'bjc-ecommerce::tomcat'
include_recipe 'bjc-ecommerce::cart'
include_recipe 'bjc-ecommerce::ssl'
