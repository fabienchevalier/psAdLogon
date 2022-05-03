# psAdLogon
A tool that you can use to monitor Active Directory user's logging activity then export the data to a .csv file.

# Usage

Download the script then launch it on a DC that you wish to audit 

OR

Open a PowerShell instance in Administrator on the DC then copy/paste :

``` powershell
$psAdLogon = Invoke-WebRequest https://raw.githubusercontent.com/fabienchevalier/psAdLogon/main/psAdLogon.ps1 && Invoke-Expression $($psAdLogon.Content)
```




