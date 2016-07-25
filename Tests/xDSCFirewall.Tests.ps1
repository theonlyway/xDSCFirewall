Import-Module .\DSCResources\xDSCFirewall\xDSCFirewall.psm1

InModuleScope XDSCFirewall {
  $Firewall = New-Object PSObject -Property @{
    Enabled = $true
    LogAllowed = $false
    LogBlocked = $true
    LogIgnored = "NotConfigured"
    LogMaxSizeKilobytes = "4096"
    DefaultInboundAction = "Block"
    DefaultOutboundAction = "Allow"
  }

  Describe "Testing if functions return correct objects" {

    It "Get-TargetResource returns a hashtable" {
      Get-TargetResource -Zone Public -Ensure Present | Should Be 'System.Collections.Hashtable'
    }

    It "Test-TargetResource returns true or false" {
      (Test-TargetResource -Zone Public -Ensure "Present").GetType() -as [string] | Should Be 'bool'
    }
  }

  Describe "Testing Get-TargetResource results" {
    $Firewall.Enabled = $false
    Mock Get-NetFirewallProfile -MockWith { $Firewall }
    It "Firewall disabled while Test-TargetResource should return absent in hash table" {
      (Get-TargetResource -Zone Public -Ensure Present).Ensure | Should Be 'Absent'
    }

    $Firewall.Enabled = $true
    Mock Get-NetFirewallProfile -MockWith { $Firewall }
    It "Firewall enabled while Test-TargetResource should return present in hash table" {
      (Get-TargetResource -Zone Public -Ensure Present).Ensure | Should Be 'Present'
    }
  }
  Describe "Disabling Firewall with Set-TargetResource" {

    It "Disabling firewall and configuring with values" {
      Set-TargetResource -Zone Public -Ensure Absent -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow
    }
    Context "Testing ensure logic for Test-TargetResource" {
      $Firewall.Enabled = $false
      Mock Get-NetFirewallProfile -MockWith { $Firewall }
      It "Testing Test-TargetResource present logic should return false" {
        Test-TargetResource -Zone Public -Ensure Present -LogBlocked True -LogAllowed False -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'False'
      }
      It "Testing Test-TargetResource absent logic should return true" {
        Test-TargetResource -Zone Public -Ensure Absent -LogBlocked True -LogAllowed False -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'True'
      }
    }
    Context "Testing Test-TargetResource operater logic for absent" {
      $Firewall.Enabled = $false
      Mock Get-NetFirewallProfile -MockWith { $Firewall }
      It "LogBlocked shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Absent -LogBlocked False -LogAllowed False -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'False'
      }
      It "LogAllowed shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Absent -LogBlocked True -LogAllowed True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'False'
      }
      It "LogIgnored shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Absent -LogAllowed False -LogBlocked True -LogIgnored False -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'False'
      }
      It "LogMaxSizeKilobytes shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Absent -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 1024 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'False'
      }
      It "DefaultInboundAction shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Absent -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Allow -DefaultOutboundAction Allow | Should Be 'False'
      }
      It "DefaultInboundAction shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Absent -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Block | Should Be 'False'
      }
    }
  }
  Describe "Enabling Firewall with Set-TargetResource" {

    It "Enabling firewall and configuring with values" {
      Set-TargetResource -Zone Public -Ensure Present -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow
    }
    Context "Testing ensure logic for Test-TargetResource" {
      $Firewall.Enabled = $true
      Mock Get-NetFirewallProfile -MockWith { $Firewall }
      It "Testing Test-TargetResource present logic should return true" {
        Test-TargetResource -Zone Public -Ensure Present -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'true'
      }
      It "Testing Test-TargetResource absent logic should return false" {
        Test-TargetResource -Zone Public -Ensure Absent -LogBlocked True -LogAllowed False -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'false'
      }
    }
    Context "Testing ensure logic" {
      $Firewall.Enabled = $true
      Mock Get-NetFirewallProfile -MockWith { $Firewall }
      It "LogBlocked shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Present -LogBlocked False -LogAllowed False -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'False'
      }
      It "LogAllowed shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Present -LogBlocked True -LogAllowed True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'False'
      }
      It "LogIgnored shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Present -LogAllowed False -LogBlocked True -LogIgnored False -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'False'
      }
      It "LogMaxSizeKilobytes shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Present -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 1024 -DefaultInboundAction Block -DefaultOutboundAction Allow | Should Be 'False'
      }
      It "DefaultInboundAction shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Present -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Allow -DefaultOutboundAction Allow | Should Be 'False'
      }
      It "DefaultInboundAction shouldn't match so should return false" {
        Test-TargetResource -Zone Public -Ensure Present -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 -DefaultInboundAction Block -DefaultOutboundAction Block | Should Be 'False'
      }
    }
  }
}