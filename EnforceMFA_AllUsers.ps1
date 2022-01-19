# This script requires MSOnline, please run "Install-Module MSOnline" before using this.

#Import and connect to MSonline
Import-Module MSOnline
$Credentials = Get-Credential
Connect-MsolService -Credential $Credentials

function Set-MfaState {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        $ObjectId,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateSet("Disabled","Enabled","Enforced")]
        [string]$State
    )
    Process {
        $Requirements = @()
        if ($state -ne "Disabled") {
            $Requirement =
                [Microsoft.Online.Administration.StrongAuthenticationRequirement]::new()
            $Requirement.RelyingParty = "*"
            $Requirement.State = $State
            $Requirements += $Requirement
        }
        Set-MsolUser -ObjectId $ObjectId -UserPrincipalName $UserPrincipalName -StrongAuthenticationRequirements $Requirements
    }
}

$Users = Get-MsolUser -All 
foreach ($user in $users) {
    $name = $user.UserPrincipalName
    $objectid = $user.ObjectId
    $state = "Enforced"
    Set-MfaState $objectid $name $state
}
