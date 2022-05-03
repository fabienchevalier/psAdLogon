# psAdLogon
A tool that you can use to monitor Active Directory user's logging activity then export the data to a .csv file.

# Usage

Download the script then launch it on a DC that you wish to audit 

OR

Open a PowerShell instance with Admin privileges on the DC then copy/paste :

``` powershell
$psAdLogon = curl https://raw.githubusercontent.com/fabienchevalier/psAdLogon/main/psAdLogon.ps1; Invoke-Expression $($psAdLogon.Content)
```

:exclamation: :exclamation: Running the script directly via GitHub may present some risks for your server as it runs with full privileges. I would recommand you to download the .ps1 file, check what's inside prior doing so.




