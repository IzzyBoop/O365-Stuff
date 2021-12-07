#IN PROGRESS, NOT FINISHED

# This script requires MSOnline, please run "Install-Module MSOnline" before using this.

#Import and connect to MSonline
Import-Module MSOnline
$Credentials = Get-Credential
Connect-MsolService -Credential $Credentials

function Set-MfaState {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $ObjectId,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $UserPrincipalName,
        [ValidateSet("Disabled","Enabled","Enforced")]
        $State
    )
    Process {
        Write-Verbose ("Setting MFA state for user '{0}' to '{1}'." -f $ObjectId, $State)
        $Requirements = @()
        if ($State -ne "Disabled") {
            $Requirement =
                [Microsoft.Online.Administration.StrongAuthenticationRequirement]::new()
            $Requirement.RelyingParty = "*"
            $Requirement.State = $State
            $Requirements += $Requirement
        }
        Set-MsolUser -ObjectId $ObjectId -UserPrincipalName $UserPrincipalName `
                     -StrongAuthenticationRequirements $Requirements
    }
}

$Users = Get-MsolUSer -All 
foreach ($user in $users) {
    Set-MfaState($user.ObjectId, $User.UserPrincipalName, "Enforced")
}

