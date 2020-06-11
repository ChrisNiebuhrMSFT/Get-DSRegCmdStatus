<#
.SYNOPSIS
   Converts the Results of the dsregcmd /status command to a more useable Powershell-Object
.DESCRIPTION
Converts the Results of the dsregcmd /status command to a more useable Powershell-Object
It is also possible to decode the Settings-URLs
.EXAMPLE
Get-DSRegCmdStatus
.EXAMPLE
Get-DSRegCmdStatus -DecodeSettingsURL
.NOTES
Author:  Microsoft (ChNieb@Microsoft.com)
Version: 1.0
Date:    11/06/2019
#>
function Get-DSRegCmdStatus
{
    [CmdletBinding()]
    Param
    (
        [switch]
        $DecodeSettingsURL #Use the switch to decode the SettingsURL which is Base64 encrypted by default
    )
    Write-Verbose 'Executing dsregcmd.exe /status'
    [string[]]$res =& $env:windir\system32\dsregcmd.exe /status  

    $result = New-Object PSObject
    #Parse the results with a Simple Reg-Ex
    Write-Verbose 'Converting the following Properties:'
    foreach ($r in $res)
    {
        if ($r -match "(?<Prop>.+?):(?<Val>.+)")
        {
            $propertyName = $Matches.Prop.Trim()
            $value = $Matches.Val.Trim()
            Write-Verbose "`t$propertyName"
            $result = $result | Add-Member -MemberType NoteProperty -Name $propertyName -Value $value  -PassThru
            if ($DecodeSettingsURL)
            {
                if ($propertyName.Equals('SettingsUrl'))
                {
                    $bytes = [System.Convert]::FromBase64String($value)
                    $decodedURL = [System.Text.Encoding]::UTF8.GetString($bytes) 
                    $result = $result | Add-Member -MemberType NoteProperty -Name 'SettingsUrlDecoded' -Value $decodedURL  -PassThru
                }
            }
        }
    }
    $result
}

$result = Get-DSRegCmdStatus -DecodeSettingsURL
$result

