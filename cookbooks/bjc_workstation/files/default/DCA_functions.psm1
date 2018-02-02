function DCA-Bootstrap-SSH {
  param (
    $name,
    $env,
    $cookbook,
    $recipe
  )
  Write-Output "Bootstrapping host $name into $env with recipe $cookbook::$recipe"
  knife bootstrap $name -N $name -E $env -r "'''recipe[$cookbook::$recipe]'''" -i ~/.ssh/id_rsa -x ubuntu --sudo -y
}

function DCA-Nuke-Automate {
  Write-Output "TERMINATING..."
  ssh automate "sudo curl -X DELETE 'http://localhost:9200/_all' && sudo automate-ctl reconfigure"
}

function DCA-AWS-Create {
  param (
    $env,
    $cookbook,
    $recipe
  )
  Write-Output "Running knife-ec2 to bootstrap node in $env"
  knife ec2 server create -r "'''recipe[$cookbook::$recipe]'''" -f m4.large -E $env -S chef_demo_2x --image ami-70b67d10 --security-group-ids sg-1cea9178 -T instance-type=DCA-kitchen-ec2 -i ~/.ssh/id_rsa --user-data C:\Users\chef\ubuntu_user_data -x ubuntu --use-iam-profile
}

function Update-RunLists {
    param (
        $env,
        $cookbook,
        $recipe
    )
    Write-Output "Adding the $cookbook::$recipe to nodes in $env"
    foreach( $node in ` knife node list -E $env ` ) {
    knife node run_list add $node "'''recipe[$cookbook::$recipe]'''"
    }
}

function Invoke-ChefClient {
    param($env)

    Write-Output "Running Chef-Client on all nodes in $env"
    knife ssh "chef_environment:$env" 'sudo chef-client'

}

function DCA-Update-Nodes {
  param(
    $env,
    $cookbook,
    $recipe
  )
  $environment = $env
  if ($env -match "awsdev"){
  } elseif ($env -match "dev"){
    $environment = "development"
  } elseif ($env -match "sta"){
    $environment = "staging"
  } elseif ($env -match "prod"){
    $environment = "production"
  }

  Write-Output "Updating nodes in $environment with $cookbook::$recipe."
  foreach( $node in ` knife node list -E $environment ` ) {
    knife node run_list add $node "'''recipe[$cookbook::$recipe]'''"
  }
  Write-Output "Converging nodes in the $environment environment"
  knife ssh "chef_environment:$environment" 'sudo chef-client'
}
