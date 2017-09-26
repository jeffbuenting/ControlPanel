
# -------------------------------------------------------------------------------------
#  File and Folder 
#--------------------------------------------------------------------------------------

Function Get-CPFolderOption {

<#
    .Synopsis
        Retrieves the Control Panel Folder Options

    .Description
        Retrieves the Folder Options from the control panel.  Options such as Hide Known file Extensions.

    .Parameter ComputerName
        Name of the computer to retrieve the info from. 

    .Example
        Gets the folder options from the local computer
        
        Get-CPFolderOption 

    .Link
        http://stackoverflow.com/questions/4491999/configure-windows-explorer-folder-options-through-powershell

    .Notes
        I found the solution at the included link to set the options.  I added the function wrapper and a Get function to check for the settings

    .Notes
        Author : Jeff Buenting
        Date : 2016 APR 01
#>

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [String[]]$ComputerName = "$($env:COMPUTERNAME).$($env:userdnsdomain)"
    )

    Process {
        foreach ( $C in $ComputerName ) {
            Write-Verbose "Get-CPFolderOption : Getting folder options for computer: $ComputerName"

            if ( -Not (Test-Connection -ComputerName $C -Quiet) ) { 
                Write-Error "Get-CPFolderOption : Computer $Computername does not exits"
                Break
            }
            
            $FolderOptions = Invoke-Command -ComputerName $C -scriptblock {
                Write-Output (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced')
            }

            # ----- Add computername to the object
            $FolderOptions | Add-Member -MemberType NoteProperty -Name Computer -Value $C

            Write-output $FolderOptions
        }
    }    
}

#--------------------------------------------------------------------------------------

Function Set-CPFolderOption {

<#
    .Synopsis
        Sets the Folder Options.

    .Description
        Sets the Folder Options in the Control Panel.

        including one of the switches toggles the setting.  If it is already 0 then it flips it to 1.  If already 1 then it flips to 0.

    .Parameter ComputerName
        Name of the computer to configure.

    .parameter HideEmptyDrives
        When set to 1 drives with no data will be hidden.

    .Parameter HideFileExt
        File extensions hidden when set to 1

    .parameter ShowSuperHidden
        Hides command files.

    .Example
        Set computer to show extensions

        $Options = Get-CPFolderOption -ComputerName ServerA 
        if ( $Options.HideFileExt -ne1 ) { Set-CPFolderOption -ComputerName ServerA -HidFileExt }

    .Notes
        Must close and reopen Folder options to see the results in the GUI.  
        Results show up on registry immediately.

    .Notes
        Author : Jeff Buenting
#>

 [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [String[]]$ComputerName = "$($env:COMPUTERNAME).$($env:userdnsdomain)",

        [Switch]$ShowSuperHidden,

        [Switch]$HideEmptyDrives,

        [Switch]$hideFileExt
    )

    Process {
        Foreach ( $C in $ComputerName ) {
            Write-Verbose "Set-CPFolderOption : Setting folder options for computer: $ComputerName"
            
            if ( -Not (Test-Connection -ComputerName $C -Quiet) ) { 
                Write-Error "Set-CPFolderOption : Computer $Computername does not exits"
                Break
            } 
            
            $FolderOptions = Get-CPFolderOption 
            
            # ----- Show Hidden Files, folders and drives
            if ( $ShowSuperHidden ) {
                Write-Verbose "Set-CPFolderOption : Setting Show Hidden Files, Folders and Drives"
                invoke-command -ComputerName $C -ArgumentList ([int](-Not $FolderOptions.ShowSuperHidden)) -scriptblock {
                    Param (
                        [Int]$Value
                    )
                    Set-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowSuperHidden -value $Value
                }
            }

            # ----- HideEmptyDrives
            if ( $HideEmptyDrives ) {
                Write-Verbose "Set-CPFolderOption : Setting Hide Empty Drives"
                invoke-command -ComputerName $C -ArgumentList ([int](-Not $FolderOptions.HideDrivesWithNoMedia)) -scriptblock {
                    Param (
                        [Int]$Value
                    )
                    Set-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideDrivesWithNoMedia -value $Value
                }
            }

            # ----- HideFileExt
            if ( $HideFileExt ) {
                Write-Verbose "Set-CPFolderOption : Setting Hide File Extensions"
                invoke-command -ComputerName $C -ArgumentList ([int](-Not $FolderOptions.HideFileExt)) -scriptblock {
                    Param (
                        [Int]$Value
                    )
                    Set-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideFileExt -value $Value
                }
            }

        }
    }
}
