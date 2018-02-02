Write-Host -ForegroundColor Green "[1/12] Logging into automate with inspec"
inspec compliance login_automate https://automate.automate-demo.com --insecure --user='workstation-1' --ent='automate-demo' --dctoken='93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506'

Write-Host -ForegroundColor Green "[2/12] Uploading Planex Validation Profile"
cd C:\Users\chef\dca\
inspec archive C:\Users\chef\profiles\planex_validate
inspec compliance upload C:\Users\chef\dca\planex_validate-0.1.0.tar.gz

Write-Host -ForegroundColor Green "[3/12] Installing bjc-ecommerce on build nodes"

Workflow buildnode-update {
  foreach -parallel ($node in @("build-node-1","build-node-2","build-node-3")) {
    ssh $node "sudo chef-client -o '''recipe[bjc-ecommerce::tksetup],recipe[bjc-ecommerce]'''"
  }
}

cd ~
buildnode-update

Write-Host -ForegroundColor Green "[4/12] Assimilating Hostsfile"

$hostsfile = "C:\Windows\System32\drivers\etc\hosts"

"172.31.54.101" + "`t`t" + "dev1" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.102" + "`t`t" + "dev2" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.103" + "`t`t" + "stage1" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.104" + "`t`t" + "stage2" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.51" + "`t`t" + "prod1" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.52" + "`t`t" + "prod2" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.53" + "`t`t" + "prod3" | Out-File -encoding ASCII -append $hostsfile

Write-Host -ForegroundColor Green "[5/12] Updating Automate Hostsfile"

ssh automate 'echo "172.31.54.101  dev1" | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.102  dev2"  | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.103  stage1" | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.104  stage2" | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.51  prod1" | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.52  prod2" | sudo tee --append /etc/hosts'
ssh automate 'echo "172.31.54.53  prod3" | sudo tee --append /etc/hosts'


Write-Host -ForegroundColor Green "[6/12] Hardening Infra Nodes"

Workflow infra-harden {
  foreach -parallel ($node in @("dev1", "dev2", "stage1", "stage2", "prod1", "prod2", "prod3") ) {
    ssh $node "sudo chef-client -o '''recipe[dca_demo::hardening]'''"
  }
}

cd ~
infra-harden

Write-Host -ForegroundColor Green "[7/12] Deleting nodes from Chef Server"

Workflow delete-nodes {
  foreach -parallel ($node in @("ecomacceptance","union","rehearsal","delivered","build-node-1","build-node-2","build-node-3")) {
      knife node delete $node -y
      ssh $node "sudo rm -Rf /etc/chef"
  }
}

delete-nodes

Write-Host -ForegroundColor Green "[8/12] Nuking Automate Data"

ssh automate "sudo curl -X DELETE 'http://localhost:9200/_all' && sudo automate-ctl reconfigure"

Write-Host -ForegroundColor Green "[9/12] Updating path and loading custom functions."
$env:path = "C:\Users\chef\dca;$env:path"
Import-Module DCA_functions

Write-Host -ForegroundColor Green "[10/12] Updating knife config with aws region"
"knife[:region] = 'us-west-2'" | Out-File -encoding ASCII -append C:\Users\chef\.chef\knife.rb

Write-Host -ForegroundColor Green "[11/12] Creating new environments"
Workflow env-create {
  foreach -parallel ($env in @("awsdev","development","staging","production")) {
    knife environment create $env -d $env
  }

}

env-create

Write-Host -ForegroundColor Green "[11/12] Opening Chrome Tabs & Cmder"
start-process "chrome.exe" "https://automate.automate-demo.com/", '--profile-directory="Default"'
start-process "chrome.exe" "https://prod1/cart",'--profile-directory="Default"'
start-process "chrome.exe" "https://dev1/cart",'--profile-directory="Default"'

& C:\tools\cmder\Cmder.exe
