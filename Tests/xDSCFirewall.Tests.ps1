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

  Describe "Testing if functions return correct objects" {

    It "Get-TargetResource returns a hashtable" {
      Get-TargetResource -Zone $Zone -Ensure $EnsurePresent | Should Be 'System.Collections.Hashtable'
    }

    It "Test-TargetResource returns true or false" {
      (Test-TargetResource -Zone $Zone -Ensure "Present").GetType() -as [string] | Should Be 'bool'
    }
  }

    Describe "Testing Get-TargetResource results" {
    $Firewall.Enabled = $false
    Mock Get-NetFirewallProfile -MockWith { $Firewall }
    It "Firewall disabled while Test-TargetResource should return absent in hash table" {
      (Get-TargetResource -Zone $Zone -Ensure $EnsurePresent).Ensure | Should Be 'Absent'
    }

    $Firewall.Enabled = $true
    Mock Get-NetFirewallProfile -MockWith { $Firewall }
    It "Firewall enabled while Test-TargetResource should return present in hash table" {
      (Get-TargetResource -Zone $Zone -Ensure $EnsurePresent).Ensure | Should Be 'Present'
    }
  }
    Describe "Testing Set-TargetResource" {

    It "Disabling firewall and configuring with values" {
      $result = Set-TargetResource -Zone $Zone -Ensure Absent -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 `
         -DefaultInboundAction Block -DefaultOutboundAction Allow
    }
  }

  Describe "Firewall disabled Testing ensure present logic for Test-TargetResource" {
    $Firewall.Enabled = $false
    Mock Get-NetFirewallProfile -MockWith { $Firewall }

    It "Firewall is disabled while ensure present is set so should return false" {
      Test-TargetResource -Zone $Zone -Ensure $EnsurePresent | Should Be 'False'
    }
  }

  Describe "Firewall disabled Testing ensure absent logic for Test-TargetResource" {
    $Firewall.Enabled = $false
    Mock Get-NetFirewallProfile -MockWith { $Firewall }

    It "Firewall is disabled while ensure absent is set so should return true" {
      Test-TargetResource -Zone $Zone -Ensure $EnsureAbsent | Should Be 'True'
    }
  }

  Describe "Testing Set-TargetResource" {

    It "Enabling firewall and configuring with values" {
      $result = Set-TargetResource -Zone $Zone -Ensure Present -LogAllowed False -LogBlocked True -LogIgnored NotConfigured -LogMaxSizeKilobytes 4096 `
         -DefaultInboundAction Block -DefaultOutboundAction Allow
    }
  }

  Describe "Firewall enabled Testing ensure present logic for Test-TargetResource" {
    $Firewall.Enabled = $true
    Mock Get-NetFirewallProfile -MockWith { $Firewall }

    It "Firewall is enabled while ensure present is set so should return true" {
      Test-TargetResource -Zone $Zone -Ensure $EnsurePresent | Should Be 'True'
    }
  }

  Describe "Firewall enabled Testing ensure absent logic for Test-TargetResource" {
    $Firewall.Enabled = $true
    Mock Get-NetFirewallProfile -MockWith { $Firewall }

    It "Firewall is enabled while ensure absent is set so should return false" {
      Test-TargetResource -Zone $Zone -Ensure $EnsureAbsent | Should Be 'false'
    }
  }

}

