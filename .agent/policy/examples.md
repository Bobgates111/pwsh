 PowerShell Code Examples

## Example 1: Advanced Function Structure
```powershell
function Get-SystemInfo {
    <#
    .SYNOPSIS
        Retrieves basic system information.
    .DESCRIPTION
        Gets OS, CPU, and Memory details as a custom object.
    .PARAMETER ComputerName
        The target computer name. Defaults to localhost.
    .EXAMPLE
        Get-SystemInfo -ComputerName "Server01"
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    process {
        foreach ($computer in $ComputerName) {
            try {
                $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
                [PSCustomObject]@{
                    ComputerName = $os.CSName
                    OSVersion    = $os.Version
                    TotalMemory  = "{0:N2} GB" -f ($os.TotalVisibleMemorySize / 1MB)
                }
            }
            catch {
                Write-Warning "Failed to retrieve info from $computer`: $_"
            }
        }
    }
}

## Example 2:Secure Credential Handling
param (
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.CredentialAttribute()]
    [PSCredential]$Credential
)

# Usage: Pass via Get-Credential or Secret Management
$secureString = $Credential.GetNetworkCredential().Password
# Do NOT write $secureString to host or logs

## Example 3: Pester Test Case
Describe 'Get-SystemInfo' {
    It 'Returns a PSCustomObject' {
        $result = Get-SystemInfo
        $result | Should -BeOfType [PSCustomObject]
    }

    It 'Contains expected properties' {
        $result = Get-SystemInfo
        $result.PSObject.Properties.Name | Should -Contain 'ComputerName'
    }
}

## Example 4: Error Handling Pattern
try {
    $content = Get-Content -Path "C:\Data\config.txt" -ErrorAction Stop
    # Process content
}
catch [System.IO.FileNotFoundException] {
    Write-Error "Configuration file not found."
    exit 1
}
catch {
    Write-Error "Unexpected error: $_"
    exit 2
}

## Example 5: Pipeline Input Support
function Invoke-Process {
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ProcessName
    )
    process {
        Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    }
}

## Example 6: WhatIf Support
function Remove-OldFiles {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$Path
    )
    if ($PSCmdlet.ShouldProcess("Files in $Path", "Remove")) {
        Remove-Item -Path "$Path\*.tmp"
    }
}

## Example 7: Cross-Platform Check
if ($IsWindows) {
    # Windows specific logic
} elseif ($IsLinux) {
    # Linux specific logic
} elseif ($IsMacOS) {
    # macOS specific logic
}