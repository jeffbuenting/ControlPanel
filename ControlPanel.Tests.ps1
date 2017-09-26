$ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path

$ModuleName = $ModulePath | Split-Path -Leaf

# ----- Remove and then import the module.  This is so any new changes are imported.
Get-Module -Name $ModuleName -All | Remove-Module -Force -Verbose

Import-Module "$ModulePath\$ModuleName.PSD1" -Force -ErrorAction Stop -Scope Global -Verbose


#-------------------------------------------------------------------------------------

Write-Output "`n`n"

Describe "ControlPanel : Get-CPFolderOption" {
    # ----- Get Function Help
    # ----- Pester to test Comment based help
    # ----- http://www.lazywinadmin.com/2016/05/using-pester-to-test-your-comment-based.html
    Context "Help" {

        $H = Help Get-CPFolderOption -Full

        # ----- Help Tests
        It "has Synopsis Help Section" {
            $H.Synopsis | Should Not BeNullorEmpty
        }

        It "has Description Help Section" {
            $H.Description | Should Not BeNullorEmpty
        }

        It "has Parameters Help Section" {
            $H.Parameters | Should Not BeNullorEmpty
        }

        # Examples
        it "Example - Count should be greater than 0"{
            $H.examples.example.code.count | Should BeGreaterthan 0
        }
            
        # Examples - Remarks (small description that comes with the example)
        foreach ($Example in $H.examples.example)
        {
            it "Example - Remarks on $($Example.Title)"{
                $Example.remarks | Should not BeNullOrEmpty
            }
        }

        It "has Notes Help Section" {
            $H.alertSet | Should Not BeNullorEmpty
        }
    } 

    

    Context Execution {
        
        Mock -CommandName Test-Connection -MockWith {
            Return $False
        }

        It "Throws and error when the computer does not exist" {
            Get-CPFolderOption -ComputerName "ServerName" 2>&1 | Should Not BeNullorEmpty
        }
    }

    Context Output {

        Mock -CommandName Test-Connection -MockWith {
            Return $True
        }

        Mock -CommandName Invoke-Command -MockWith {
            $Obj = New-Object -TypeName PSObject -Property (@{
                'HideEmptyDrives' = 0
                'ShowSuperHidden' = 0
            })

            Return $Obj
        }

        It "Should Return a custom object" {
            Get-CPFolderOption | Should beoftype PSObject
        } 
    }
}

#-------------------------------------------------------------------------------------

Write-Output "`n`n"

Describe "ControlPanel : Set-CPFolderOption" {
    # ----- Get Function Help
    # ----- Pester to test Comment based help
    # ----- http://www.lazywinadmin.com/2016/05/using-pester-to-test-your-comment-based.html
    Context "Help" {

        $H = Help Set-CPFolderOption -Full

        # ----- Help Tests
        It "has Synopsis Help Section" {
            $H.Synopsis | Should Not BeNullorEmpty
        }

        It "has Description Help Section" {
            $H.Description | Should Not BeNullorEmpty
        }

        It "has Parameters Help Section" {
            $H.Parameters | Should Not BeNullorEmpty
        }

        # Examples
        it "Example - Count should be greater than 0"{
            $H.examples.example.code.count | Should BeGreaterthan 0
        }
            
        # Examples - Remarks (small description that comes with the example)
        foreach ($Example in $H.examples.example)
        {
            it "Example - Remarks on $($Example.Title)"{
                $Example.remarks | Should not BeNullOrEmpty
            }
        }

        It "has Notes Help Section" {
            $H.alertSet | Should Not BeNullorEmpty
        }
    }
    
    Context Execution { 

        Mock -ModuleName ControlPanel -CommandName Get-CPFolderOption -MockWith {
            $Obj = New-Object -TypeName PSObject -Property (@{
                'HideEmptyDrives' = 0
                'ShowSuperHidden' = 0
                'HodeFileExt' = 0
            })

            Return $Obj
        }

        It "Throws and error when the computer does not exist" {
            Mock -CommandName Test-Connection -MockWith {
                Return $False
            }

            Get-CPFolderOption -ComputerName "ServerName" 2>&1 | Should Not BeNullorEmpty
        }

        It "calls Set-ItemProperty for each Option switch specified" {
            Mock -CommandName Test-Connection -MockWith {
                Return $True
            }

            Mock -CommandName Invoke-Command -MockWith {} 

            Set-CPFolderOption -ComputerName ServerA -ShowSuperHidden -HideEmptyDrives -hideFileExt

            Assert-MockCalled -CommandName Invoke-Command -Exactly 3
        }
    } 
}