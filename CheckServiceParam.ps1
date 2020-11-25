<#
.SYNOPSIS
  Check the server service status
.DESCRIPTION
  The script returns the service status based on the following conditions:
  1) If the server is offline it returns the status as unknown
  2) If the server is accessible it returns the current status of the service 
.PARAMETER filename.json
    Requires an input file in json format. It requires the data : Server, Service, Env
.INPUTS
  None. Inputs are defined on json file
.OUTPUTS
  Output file is stored in C:\XOM\SPTTemp\AWSM\{filename}_{today timestamp}.csv
  The {filename} of the output csv file is using the json input filename
.NOTES
  Version:        1.0
  Author:         Ho Mei Siew
  Creation Date:  19 Nov 2020
  Purpose/Change: Initial script development

  Revision update:
  Author:         
  Updated Date:   
  Purpose/Change: 
#>


# Get the script parameter - filename
Param([String]$FileNameSelected)

$JSONFromFile = Get-Content -Raw -Path $FileNameSelected | ConvertFrom-Json

$Output = @()

# Get Start Time
$StartTime = (Get-Date)

foreach ($line in $JSONFromFile) {

    # Test if the server is up before checking the service 
    $SMB = $null
    $Status=$null
    $Object=$null

    $server = $line.server
    $SMB = Test-Path -Path "\\$server\c$"

    If($SMB -eq "True") {

        $Object = Get-Service -ComputerName $line.server | Where{$_.Name -eq $line.service}

        $Object = New-Object PSObject -Property ([ordered]@{ 
            MachineName = $Object.MachineName
            Name = $Object.Name
            Status = $Object.Status
            Env = $line.env
        })
        
        $Output +=$Object
  
    }
    Else {

        $Status = "Unknown"
        $Object = New-Object PSObject -Property ([ordered]@{ 
            MachineName = $line.server
            Name = $line.service
            Status = $Status
            Env = $line.env
        })

        $Output +=$Object

    }
 
}

# Get today's date
$FileTimeStamp = Get-Date
$FileTimeStamp = $FileTimeStamp.ToString('yyyyMMdd_hh-mm-ss')

# Use the Input filename as Output filename
$OutputFileName = $FileNameSelected.Substring(0,$FileNameSelected.IndexOf('.json')) + "_" + $FileTimeStamp + ".csv"

$Output | Export-CSV -Path "C:\XOM\SPTTemp\AWSM\$OutputFileName" -NoTypeInformation

 # Get End Time
$EndTime = (Get-Date)

# Echo Time elapsed
Write-Output "Elapsed Time: $(($EndTime-$StartTime).totalseconds) seconds"