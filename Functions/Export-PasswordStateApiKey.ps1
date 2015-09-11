<#
Copyright 2015 Brandon Olin

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>

function Export-PasswordStateApiKey {
    <#
        .SYNOPSIS
            Exports a PowerShell credential object to the PasswordState key repository.
        .DESCRIPTION
            Exports a PowerShell credential object to the PasswordState key repository.
        .PARAMETER ApiKey
            PowerShell credential object to export.
        .PARAMETER Repository
            Path to repository. Default is $env:USERPROFILE\.passwordstate
        .EXAMPLE
            Export-PasswordStateApiKey -ApiKey $cred
        .EXAMPLE
            Export-PasswordStateApiKey -ApiKey $cred -Repository c:\users\joe\data\.customrepo
        .EXAMPLE
            $cred | Export-PasswordStateApiKey -Repository c:\users\joe\data\.customrepo
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [pscredential[]]$ApiKey,

        [string]$Repository = (_GetDefault -Option 'credential_repository')
    )

    begin {
        if (-not (Test-Path -Path $Repository -Verbose:$false)) {
            Write-Verbose "Creating PasswordState key repository: $Repository"
            New-Item -ItemType Directory -Path $Repository -Verbose:$false | Out-Null
        }
    }

    process {
        foreach ($item in $ApiKey) {
            $exportPath = Join-Path -path $Repository -ChildPath "$($item.Username).cred" -Verbose:$false
            Write-Verbose "Exporting key [$($item.Username)] to $exportPath"
            $item.Password | convertfrom-securestring -Verbose:$false | Out-File $exportPath -Verbose:$false
        }
    }
}