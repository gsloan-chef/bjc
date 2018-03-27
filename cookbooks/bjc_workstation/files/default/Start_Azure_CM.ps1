Write-Host -ForegroundColor Green "[1/15] Logging into automate with inspec"
inspec compliance login_automate https://automate.automate-demo.com --insecure --user='workstation-1' --ent='automate-demo' --dctoken='93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506'

Write-Host -ForegroundColor Green "[2/15] Uploading Planex Validation Profile"
cd C:\Users\chef\dca\
inspec archive C:\Users\chef\profiles\planex_validate
inspec compliance upload C:\Users\chef\dca\planex_validate-0.1.0.tar.gz

Write-Host -ForegroundColor Green "[3/15] Installing bjc-ecommerce on build nodes"

Workflow buildnode-update {
  foreach -parallel ($node in @("build-node-1","build-node-2","build-node-3")) {
    ssh $node "sudo chef-client -o '''recipe[bjc-ecommerce::tksetup],recipe[bjc-ecommerce]'''"
  }
}

cd ~
buildnode-update

Write-Host -ForegroundColor Green "[4/15] Installing Knife Azure gem"
& C:\tools\cmder\vendor\conemu-maximus5\ConEmu.exe /cmd "chef gem install knife-azure"

Write-Host -ForegroundColor Green "[5/15] Assimilating Hostsfile"

$hostsfile = "C:\Windows\System32\drivers\etc\hosts"

"172.31.54.101" + "`t`t" + "dev1" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.102" + "`t`t" + "dev2" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.103" + "`t`t" + "stage1" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.104" + "`t`t" + "stage2" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.51" + "`t`t" + "prod1" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.52" + "`t`t" + "prod2" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.53" + "`t`t" + "prod3" | Out-File -encoding ASCII -append $hostsfile

Write-Host -ForegroundColor Green "[6/15] Updating Automate Hostsfile"

ssh automate 'echo "172.31.54.101  dev1" | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.102  dev2"  | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.103  stage1" | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.104  stage2" | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.51  prod1" | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.52  prod2" | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.53  prod3" | sudo tee --append /etc/hosts'


Write-Host -ForegroundColor Green "[7/15] Hardening Infra Nodes"

Workflow infra-harden {
  foreach -parallel ($node in @("dev1", "dev2", "stage1", "stage2", "prod1", "prod2", "prod3") ) {
    ssh $node "sudo chef-client -o '''recipe[dca_demo::hardening]'''"
  }
}

cd ~
infra-harden

Write-Host -ForegroundColor Green "[8/15] Deleting nodes from Chef Server"

Workflow delete-nodes {
  foreach -parallel ($node in @("ecomacceptance","union","rehearsal","delivered","build-node-1","build-node-2","build-node-3")) {
      knife node delete $node -y
      ssh $node "sudo rm -Rf /etc/chef"
  }
}

delete-nodes

Write-Host -ForegroundColor Green "[9/15] Updating path and loading custom functions."
$env:path = "C:\Users\chef\dca;$env:path"
Import-Module DCA_functions

# Still need to find a way to make the $AZURE info persistent
Write-Host -ForegroundColor Green "[10/15] Updating Azure environment file"
$AZURE_SUBSCRIPTION_ID = Read-Host -Prompt 'Input your Azure Subscription ID'
$AZURE_TENANT_ID = Read-Host -Prompt 'Input your Azure Tenant ID'
$AZURE_CLIENT_ID = Read-Host -Prompt 'Input the http://KitchenSvc Azure Client ID'
$AZURE_CLIENT_SECRET = Read-Host -Prompt 'Input the http://KitchenSvc Azure Client Secret'
$contact = Read-Host -Prompt 'Input your Azure username [username]@chef.io'
$project = Read-Host -Prompt 'Input your Project name'
$date = [datetime]::Today.ToString('Md')
$name = [string]::format("{0}{1}{2}", $contact.Substring(0,5).toLower(), $project.Substring(0,2).toLower(), $date)
Write-Host "$contact, the Azure Cloud Migration demo for $project is almost ready to go!"

Write-Host -ForegroundColor Green "[11/15] Creating Azure knife config"
$automateservermac = ssh automate curl -s curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/
$automateserverip = ssh automate curl -s curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/$automateservermac/public-ipv4s
$chefservermac = ssh chef curl -s curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/
$chefserverip = ssh chef curl -s curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/$chefservermac/public-ipv4s

"current_dir = File.dirname(__FILE__)"  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"log_level            :info"  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"log_location         STDOUT"  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"node_name            'workstation-1'"  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"chef_server_url      'https://$chefserverip/organizations/automate'"  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"client_key           ""#{ENV['HOME']}/.chef/private.pem"""  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"trusted_certs_dir   ""#{ENV['HOME']}/.chef/trusted_certs"""   | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"cookbook_path        ""#{ENV['HOME']}/cookbooks"""  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"data_collector.server_url 'https://$automateserverip/data-collector/v0/'"  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"client_d_dir         ""#{ENV['HOME']}/.chef/config.d"""  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"knife[:azure_subscription_id]  = $AZURE_SUBSCRIPTION_ID"  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"knife[:azure_tenant_id]        = $AZURE_TENANT_ID"  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"knife[:azure_client_id]        = $AZURE_CLIENT_ID"  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"knife[:azure_client_secret]    = $AZURE_CLIENT_SECRET"  | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
"ssl_verify_mode :verify_none" | Out-File -encoding ASCII -append C:\Users\chef\knife.rb
# "verify-api-cert :no" | Out-File -encoding ASCII -append C:\Users\chef\knife.rb


Write-Host -ForegroundColor Green "[12/15] Creating new environments"
Workflow env-create {
  foreach -parallel ($env in @("azuredev","development","staging","production")) {
    knife environment create $env -d $env
  }

}

env-create

Write-Host -ForegroundColor Green "[13/15] Launching initial AzureRM instance"
#& C:\tools\cmder\vendor\conemu-maximus5\ConEmu.exe /cmd "knife azurerm server create -E azuredev --azure-resource-group-name cm_azure_demo --azure-vm-name $name --azure-service-location 'westus' --azure-image-os-type ubuntu --azure-image-reference-sku '14.04.2-LTS' --ssh-user ubuntu --ssh-password C0d3C@n! --azure-vm-size Small --no-node-verify-api-cert -c /Users/chef/knife.rb" -cur_console:c1
& C:\tools\cmder\vendor\conemu-maximus5\ConEmu.exe /cmd "knife azurerm server create -E azuredev --azure-resource-group-name cm_azure_demo --azure-vm-name $name --azure-service-location 'westus' --azure-image-os-type ubuntu --azure-image-reference-sku '14.04.2-LTS' --ssh-user ubuntu --ssh-password C0d3C@n! --azure-vm-size Small --no-node-verify-api-cert --node-ssl-verify-mode none -c /Users/chef/knife.rb" -cur_console:c1


$azurenodes = 0
while($azureup -eq 0){
  "Waiting for Azure Instance..."
  Start-Sleep 10
  $azurenodes = knife search node 'chef_environment:azuredev' -i | wc -l
}

Write-Host -ForegroundColor Green "[14/15] Nuking Automate Data"

ssh automate "sudo curl -X DELETE 'http://localhost:9200/_all' && sudo automate-ctl reconfigure"


Write-Host -ForegroundColor Green "[15/15] Opening Chrome Tabs & Cmder"
start-process "chrome.exe" "https://automate.automate-demo.com/", '--profile-directory="Default"'
start-process "chrome.exe" "https://prod1/cart",'--profile-directory="Default"'
start-process "chrome.exe" "https://dev1/cart",'--profile-directory="Default"'

& C:\tools\cmder\Cmder.exe
