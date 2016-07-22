Import-Module .\DSCResources\xDSCFirewall\xDSCFirewall.psm1

InModuleScope XDSCFirewall {
  $Zone = "Public"
  $EnsurePresent = "Present"
  $EnsureAbsent = "Absent"
  $Firewall = New-Object PSObject -Property @{
    Enabled = $true
    LogAllowed = $false
    LogBlocked = $false
    LogIgnored = "NotConfigured"
    LogMaxSizeKilobytes = "4096"
    DefaultInboundAction = "NotConfigured"
    DefaultOutboundAction = "NotConfigured"
  }

  Describe "Checking if functions return correct objects" {

    It "Get-TargetResource return a hashtable" {
      Get-TargetResource -Zone $Zone | Should Be 'System.Collections.Hashtable'
    }

    It "Test-TargetResource return true or false" {
      (Test-TargetResource -Zone $Zone -Ensure "Present").GetType() -as [string] | Should Be 'bool'
    }
  }

  Describe "Checking Set-TargetResource" {

    It "Enabling firewall and configuring with values" {
      $result = Set-TargetResource -Zone $Zone -Ensure Present -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 `
         -DefaultInboundAction Block -DefaultOutboundAction Allow
    }
  }

  Describe "Firewall enabled checking ensure present logic for Test-TargetResource" {
    $Firewall.Enabled = $true
    Mock Get-NetFirewallProfile -MockWith { $Firewall }

    It "Firewall is enabled while ensure present is set so should return true" {
      Test-TargetResource -Zone $Zone -Ensure $EnsurePresent | Should Be 'True'
    }
    It "Firewall is enabled while ensure absent is set so should return false" {
      Test-TargetResource -Zone $Zone -Ensure $EnsureAbsent | Should Be 'False'
    }
  }

  Describe "Firewall disabled checking ensure present logic for Test-TargetResource" {
    $Firewall.Enabled = $false
    Mock Get-NetFirewallProfile -MockWith { $Firewall }

    It "Firewall is disabled while ensure present is set so should return false" {
      Test-TargetResource -Zone $Zone -Ensure $EnsurePresent | Should Be 'False'
    }
    It "Firewall is disabled while ensure absent is set so should return true" {
      Test-TargetResource -Zone $Zone -Ensure $EnsureAbsent | Should Be 'True'
    }
  }
}

