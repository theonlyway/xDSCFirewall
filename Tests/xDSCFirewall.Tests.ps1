Import-Module ..\DSCResources\xDSCFirewall\xDSCFirewall.psm1

    $Zone = "Public"
    $EnsurePresent = "Present"
    $EnsureAbsent = "Absent"
    $Firewall = Get-NetFirewallProfile $Zone | Select-Object Enabled,LogAllowed,LogBlocked,LogIgnored,LogMaxSizeKilobytes,DefaultInboundAction,DefaultOutboundAction

InModuleScope XDSCFirewall {
Describe "Checking if functions return correct objects" {
Mock Export-ModuleMember {return $true}

    It "Get-TargetResource return a hashtable" {
        Get-TargetResource -Zone $Zone | Should Be 'System.Collections.Hashtable'
    }

    It "Get-TargetResource return true or false" {
        (Test-TargetResource -Zone $Zone -Ensure "Present").GetType() -as [string] | Should Be 'bool'
    }
}


Describe "Firewall enabled checking ensure present logic for Test-TargetResource" {
    Mock Export-ModuleMember {return $true}
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
    Mock Export-ModuleMember {return $true}
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