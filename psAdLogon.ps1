<#           
             ___      _ _                             
            / _ \    | | |                            
 _ __  ___ / /_\ \ __| | |     ___   __ _  ___  _ __  
| '_ \/ __||  _  |/ _` | |    / _ \ / _` |/ _ \| '_ \ 
| |_) \__ \| | | | (_| | |___| (_) | (_| | (_) | | | |
| .__/|___/\_| |_/\__,_\_____/\___/ \__, |\___/|_| |_|
| |                                  __/ |            
|_|                                 |___/             

Author      : Fabien CHEVALIER
GitHub      : https://github.com/fabienchevalier/psAdLogon/
Description : A tool that you can use to monitor Active Directory user's logging activity and export it to CSV
Usage       : Launch 
#>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# -> All Last Logon
Function psAllLastLogon{
    Clear-Host
    Write-Host -ForegroundColor Yellow "[i] Gathering user's last logon on $env:computername."
    $LastLogon = Get-ADUser -Filter * -Properties LastLogon | Select-Object Name, @{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}}
    Write-Host -ForegroundColor Yellow "[i] Processing..."
    $LastLogon | Out-GridView
    Write-Host -ForegroundColor Green "[✓] Done."
    $Path = "$pwd\LastLogon_"+(Get-Date -format "dd-MM-yyyy@HH-mm")+".csv"
    Write-Host -ForegroundColor Yellow "[i] Exporting data to $Path"
    $LastLogon | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
    Write-Host -ForegroundColor Green "[✓] Done."
}
# <- End of Last Logon

# -> Check all AD's users logon history
Function psAdLogon {
    ## Calendar GUI
    $form = New-Object Windows.Forms.Form -Property @{
        StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
        Size          = New-Object Drawing.Size 243, 230
        Text          = 'Select a Date'
        Topmost       = $true
    }

    $calendar = New-Object Windows.Forms.MonthCalendar -Property @{
        ShowTodayCircle   = $false
        MaxSelectionCount = 1
    }
    $form.Controls.Add($calendar)

    $okButton = New-Object Windows.Forms.Button -Property @{
        Location     = New-Object Drawing.Point 38, 165
        Size         = New-Object Drawing.Size 75, 23
        Text         = 'OK'
        DialogResult = [Windows.Forms.DialogResult]::OK
    }
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object Windows.Forms.Button -Property @{
        Location     = New-Object Drawing.Point 113, 165
        Size         = New-Object Drawing.Size 75, 23
        Text         = 'Cancel'
        DialogResult = [Windows.Forms.DialogResult]::Cancel
    }
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $GUI = $form.ShowDialog()

    If ($GUI -eq [Windows.Forms.DialogResult]::OK) 
    {
        $Date = $calendar.SelectionStart
        Write-Host -ForegroundColor Yellow "[i] Date selected: $($date.ToShortDateString())"
    }
    Write-Host -ForegroundColor Yellow "[i] Gathering Event Logs on $env:computername, this could take a while..."
    $Date = $Date.AddDays(1)
    $Logs = Get-EventLog System -Source Microsoft-Windows-WinLogon -Before $Date -After $Date.AddDays(-1) -ComputerName $env:computername
    $Result = @() 
    If ($Logs){ 
            Write-Host -ForegroundColor Yellow "[i] Processing..."
            ForEach ($Log in $Logs)
            { 
                If ($Log.InstanceId -eq 7001){
                        $ET = "Logon"
                    }
                ElseIf ($Log.InstanceId -eq 7002){ 
                        $ET = "Logoff"
                    }
                Else{ 
                    Continue
                    }
                $Result += New-Object PSObject -Property @{Time = $log.TimeWritten; "Event Type" = $ET; 
                User = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount]) #<- On peut sûrement récupérer le user via ici
                }
            }
            $Result | Select-Object Time,"Event Type",User | Sort Time -Descending | Out-GridView
            Write-Host -ForegroundColor Green "[✓] Done."
            $Path = "$pwd\LogonHistory_"+(Get-Date -format "dd-MM-yyyy@HH-mm")+".csv"
            Write-Host -ForegroundColor Yellow "[i] Exporting data to $Path."
            $Result | Select-Object Time,"Event Type",User | Sort Time -Descending | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
            Write-Host -ForegroundColor Green "[✓] Done."
        }
    Else{
            Write-Host -ForegroundColor Red "[x] Something went wrong with Event Log quering. Please check the date you wish to check and try again."
        }    
}
    
# <- End of  check all AD's users logon history

# -> Main program

Clear-Host
Write-Host @"
             ___      _ _                             
            / _ \    | | |                            
 _ __  ___ / /_\ \ __| | |     ___   __ _  ___  _ __  
| '_ \/ __||  _  |/ _` | |    / _ \ / _` |/ _ \| '_ \ 
| |_) \__ \| | | | (_| | |___| (_) | (_| | (_) | | | |
| .__/|___/\_| |_/\__,_\_____/\___/ \__, |\___/|_| |_|
| |                                  __/ |            
|_|                                 |___/             
V.0.0.1  - 02/05/2022 - https://github.com/fabienchevalier/psAdLogon/

What do you wanna do?
    1 - Check all users's last logging
    2 - Check AD users's loggon history at a choosen date 

"@

$Choice = Read-Host "[1/2]"

If ($Choice -eq 1){
    psAllLastLogon
    Pause
}
ElseIf($Choice -eq 2){
    psAdLogon
    Pause
}
