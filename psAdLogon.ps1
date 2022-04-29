<#            ___      _ _                             
            / _ \    | | |                            
 _ __  ___ / /_\ \ __| | |     ___   __ _  ___  _ __  
| '_ \/ __||  _  |/ _` | |    / _ \ / _` |/ _ \| '_ \ 
| |_) \__ \| | | | (_| | |___| (_) | (_| | (_) | | | |
| .__/|___/\_| |_/\__,_\_____/\___/ \__, |\___/|_| |_|
| |                                  __/ |            
|_|                                 |___/             

Author      : Fabien CHEVALIER
GitHub      : https://github.com/fabienchevalier/psAdLogon/
Description : A tool that you can use to monitor Active Directory user's logging activity
Usage       : Check the GitHub page to learn how to use this script 
#>

# -> Parameter definition

Param(
    [String]$User #Use this parameter to choose from wich user you wish to see logon history.
    [String]$L #Use this parameter to check last logon activity on the local AD server (ex ./psAdLogon -L -User John)
    [Int]$D #Use this parameter to set the amount of days you wanna look back (ex ./psAdLogon -D 12 -User John)
    [String]$A #Use this parameter to check all user's logging activity from today (ex ./psAdLogon -A -D 12)
    [String]$toCSV #Use this parameter to export results to a CSV file (ex ./psAdLogon -A -toCSV C:\path.csv)
)

# <- End of parameter definition

# -> Check prerequisites
Function CheckPrerequisites{
    If (Get-Command Get-ADDomainController -errorAction SilentlyContinue)
    {
        Write-Host -ForegroundColor Green  "ADDomainController exists : OK"
    }
    ElseIf (Get-Command $Get-ADUser -errorAction SilentlyContinue)
    {
        Write-Host -ForegroundColor Green  "ADUser exists : OK"
    }


}
# <- End of check prerequisites

# -> Global Var

$DCs = Get-ADDomainController -Filter *
$HostName = $DCs.HostName

# <- End of Global Var

# -> User Last Logon
Function psUserLastLogon{
    Clear-Host
    $Result = Get-ADUser -Identity $User -Properties LastLogon | Select-Object Name, @{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}}

}
# <- End of User Last Logon

# -> All Last Logon
Function psAllLastLogon{
    Clear-Host
    $Result = Get-ADUser -Filter * -Properties LastLogon | Select-Object Name, @{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}}
}
# <- End of Last Logon

# - Check all AD's users logon history
Function psAllLogon {
    Clear-Host
    Write-Host "Gathering Event Logs on $env:computername, this could take a while..."
    $Logs = Get-EventLog System -Source Microsoft-Windows-WinLogon -After (Get-Date).AddDays(-1) -ComputerName $env:computername
    $Result = @() 
    If ($Logs)
        { 
            Write-Host "Processing..."
            ForEach ($Log in $Logs)
            { 
                If ($Log.InstanceId -eq 4624)
                    {
                        $ET = "Logon"
                    }
                ElseIf ($Log.InstanceId -eq 4634)
                    { 
                        $ET = "Logoff"
                    }
                Else
                    { 
                    Continue
                    }
                $Result += New-Object PSObject -Property @{Time = $log.TimeWritten; "Event Type" = $ET; 
                User = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])
                }
            }
            $Result | Select-Object Time,"Event Type",User | Sort Time -Descending | Out-GridView
            Write-Host "Done."
        }
}
    
# - Check one AD user logon history
Function psAdLogon {
    $DCs = Get-ADDomainController -Filter *
    $HostName = $DCs.HostName

    ## Get SystemLog
    $Logs = Get-EventLog system -ComputerName -UserName $User $HostName -source Microsoft-Windows-Winlogon -After (Get-Date).AddDays(-1);

    $Result = @() 

    ForEach ($log in $logs) {

        If($log.instanceid -eq 7001) {
        
            $type = "Logon"

        } 

        Elseif ($log.instanceid -eq 7002){
    
          $type="Logoff"

        } 

        Else {
            Continue
        } 

        $Result += New-Object PSObject -Property @{Time = $log.TimeWritten; "Event" = $type; 
                User = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])
        }
    }
}


## -- Check if param is correctly set


$Result