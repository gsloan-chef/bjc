Write-Host -ForegroundColor Green "[1/14] Updating Trusted Certs"
cd C:\Users\chef
knife ssl fetch

Write-Host -ForegroundColor Green "[1/13] Installing bjc-ecommerce on build nodes"

Workflow buildnode-update {
  foreach -parallel ($node in @("build-node-1","build-node-2","build-node-3")) {
    ssh $node "sudo chef-client -o '''recipe[bjc-ecommerce::tksetup],recipe[bjc-ecommerce]'''"
  }
}

cd ~
buildnode-update

Write-Host -ForegroundColor Green "[2/13] Deleting existing nodes from Chef Server"
foreach($node in @("ecomacceptance","union","rehearsal","delivered","build-node-1","build-node-2","build-node-3")) {
    knife node delete $node -y
    ssh $node "sudo rm -Rf /etc/chef"
}

Write-Host -ForegroundColor Green "[3/13] Deleting local datacollector config"
Remove-Item C:\Users\chef\.chef\config.d -Recurse

Write-Host -ForegroundColor Green "[4/13] Deleting Compliance Index in Elasticsearch"
$timestamp = date +%Y.%m.%d
$compIndex = "comp-2-s-$timestamp"
ssh automate "sudo curl -X DELETE 'http://localhost:10141/$compIndex'"

Write-Host -ForegroundColor Green "[5/13] Assimilating Hostsfile"

$hostsfile = "C:\Windows\System32\drivers\etc\hosts"

"172.31.54.101" + "`t`t" + "dev1" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.102" + "`t`t" + "dev2" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.103" + "`t`t" + "stage1" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.104" + "`t`t" + "stage2" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.51" + "`t`t" + "prod1" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.52" + "`t`t" + "prod2" | Out-File -encoding ASCII -append $hostsfile
"172.31.54.53" + "`t`t" + "prod3" | Out-File -encoding ASCII -append $hostsfile

Write-Host -ForegroundColor Green "[7/13] Fetching an Admin Token"
$TOK = ssh automate 'sudo chef-automate admin-token'
Write-Host -ForegroundColor Yellow "Your admin token is: " $TOK

Write-Host -ForegroundColor Green "[7/13] Installing InSpec on Automate Server"
# NOTE: Due to a bug running inspec compliance upload from windows, we're doing this remotely on the A2 host.
# Reference: https://github.com/inspec/inspec/issues/3222
ssh automate "cd /tmp && wget https://packages.chef.io/files/stable/inspec/2.2.35/ubuntu/16.04/inspec_2.2.35-1_amd64.deb && sudo dpkg -i inspec_2.2.35-1_amd64.deb"
sleep 5

Write-Host -ForegroundColor Green "[8/13] Logging into automate with inspec"
ssh automate "inspec compliance login https://automate.automate-demo.com --insecure --user='leela' --ent='default' --token=$TOK"
sleep 5

Write-Host -ForegroundColor Green "[9/13] Uploading baseline wrapper profile"
cd C:\Users\chef\dca\
inspec archive C:\Users\chef\profiles\linux_baseline_wrapper
scp C:\Users\chef\dca\linux_baseline_wrapper-0.1.2.tar.gz ubuntu@automate:/tmp/linux_wrapper.tar.gz
ssh automate "inspec compliance upload /tmp/linux_wrapper.tar.gz"
inspec archive C:\Users\chef\profiles\windows_baseline_wrapper
scp C:\Users\chef\dca\windows_baseline_wrapper-0.1.2.tar.gz ubuntu@automate:/tmp/windows_wrapper.tar.gz
ssh automate "inspec compliance upload /tmp/windows_wrapper.tar.gz"


Write-Host -ForegroundColor Green "[10/13] Rebootstrapping nodes."

Foreach ($env in @("development","staging","production")) {
  knife environment create $env -d $env
}

Workflow rebootstrapper {
  Parallel {
    Foreach -Parallel ($node in @("dev1","dev2")) {
      knife bootstrap $node -N $node -E development -i ~/.ssh/id_rsa -x ubuntu --sudo -y
    }

    Foreach -Parallel ($node in @("stage1","stage2")) {
      knife bootstrap $node -N $node -E staging -i ~/.ssh/id_rsa -x ubuntu --sudo -y
    }

    Foreach -Parallel ($node in @("prod1","prod2","prod3")) {
      knife bootstrap $node -N $node -E production -i ~/.ssh/id_rsa -x ubuntu --sudo -y
    }

  }
}

rebootstrapper

Write-Host -ForegroundColor Green "[11/13] Updating cmder directory"
ForEach ($file in @("C:\tools\cmder\config\user-ConEmu.xml","C:\tools\cmder\config\user-ConEmu.xml")){
if ( $(Try { Test-Path $file } Catch { $false }) ) {
   rm $file
 }
Else {
    Write-Host "Cmder config file not Found. Skipping."
 }
}
sed -i -e "s/bjc-ecommerce/dca_demo/g" C:\tools\cmder\config\ConEmu.xml

Write-Host -ForegroundColor Green "[12/13] Opening Chrome Tabs & Cmder"
start-process "chrome.exe" "https://automate.automate-demo.com/", '--profile-directory="Default"'
start-process "chrome.exe" "https://dev1/cart",'--profile-directory="Default"'
start-process "chrome.exe" "https://dev2/cart",'--profile-directory="Default"'

Write-Host -ForegroundColor Green "[13/13] Updating path and loading custom functions."
$env:path = "C:\Users\chef\dca;$env:path"
Import-Module DCA_functions

# Uncomment to open e-mails.
# & ${env:userprofile}\dca\DCA_email_wk1.html

& C:\tools\cmder\Cmder.exe
cd ${env:userprofile}\cookbooks\dca_demo
git init .
git add .
git commit -m "initial dca_demo cookbook"
code .

Read-Host -Prompt "Press Enter to exit"
