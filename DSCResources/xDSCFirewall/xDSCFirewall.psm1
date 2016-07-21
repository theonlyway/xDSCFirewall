﻿function Get-TargetResource
{
  [CmdletBinding()]
  [OutputType([System.Collections.Hashtable])]
  param
  (
    [Parameter(Mandatory = $true)][ValidateSet("Domain","Private","Public")]
    [System.String]
    $Zone
  )
  $firewall = Get-NetFirewallProfile $Zone | Select-Object  Enabled, LogAllowed, LogBlocked, LogIgnored, LogMaxSizeKilobytes, DefaultInboundAction, DefaultOutboundAction

  if ($firewall.Enabled -eq $false) {
    return @{
      Ensure              = "Absent";
      Zone                = $Zone;
      LogAllowed          = $firewall.LogAllowed;
      LogBlocked          = $firewall.LogBlocked;
      LogIgnored          = $firewall.LogIgnored;
      LogMaxSizeKilobytes = $firewall.LogMaxSizeKilobytes;
      DefaultInboundAction = $firewall.DefaultInboundAction;
      DefaultOutboundAction = $firewall.DefaultOutboundAction;
    }
  }
  else
  {
    return @{
      Ensure              = "Present";
      Zone                = $Zone;
      LogAllowed          = $firewall.LogAllowed;
      LogBlocked          = $firewall.LogBlocked;
      LogIgnored          = $firewall.LogIgnored;
      LogMaxSizeKilobytes = $firewall.LogMaxSizeKilobytes;
      DefaultInboundAction = $firewall.DefaultInboundAction;
      DefaultOutboundAction = $firewall.DefaultOutboundAction;
    }
  }
}


function Set-TargetResource
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)][ValidateSet("Domain","Private","Public")]
    [System.String]
    $Zone,

    [Parameter(Mandatory = $true)][ValidateSet("Present","Absent")]
    [System.String]
    $Ensure,

    [Parameter()][ValidateSet("True","False","NotConfigured")]
    [System.String]$LogBlocked = "False",

    [Parameter()][ValidateSet("True","False","NotConfigured")]
    [System.String]$LogAllowed = "False",

    [Parameter()][ValidateSet("True","False","NotConfigured")]
    [System.String]$LogIgnored = "NotConfigured",

    [Parameter()]
    [System.String]$LogMaxSizeKilobytes = "4096",

    [Parameter()][ValidateSet("Allow","Block","NotConfigured")]
    [System.String]$DefaultInboundAction = "NotConfigured",

    [Parameter()][ValidateSet("Allow","Block","NotConfigured")]
    [System.String]$DefaultOutboundAction = "NotConfigured"
  )

  if ($Ensure -eq "Present")
  {
    $EnableFW = Get-NetFirewallProfile $Zone | Set-NetFirewallProfile -Enabled True -LogAllowed $LogAllowed -LogBlocked $LogBlocked -LogIgnored $LogIgnored -LogMaxSizeKilobytes $LogMaxSizeKilobytes -DefaultInboundAction $DefaultInboundAction -DefaultOutboundAction $DefaultOutboundAction
    New-EventLog -LogName "Microsoft-Windows-DSC/Operational" -Source "xDSCFirewall" -ErrorAction SilentlyContinue
    Write-EventLog -LogName "Microsoft-Windows-DSC/Operational" -Source "xDSCFirewall" -EventId 3001 -EntryType Information -Message "Firewall zone $zone was enabled"
  }
  elseif ($Ensure -eq "Absent")
  {
    $DisableFW = Get-NetFirewallProfile $Zone | Set-NetFirewallProfile -Enabled False -LogAllowed $LogAllowed -LogBlocked $LogBlocked -LogIgnored $LogIgnored -LogMaxSizeKilobytes $LogMaxSizeKilobytes -DefaultInboundAction $DefaultInboundAction -DefaultOutboundAction $DefaultOutboundAction
    New-EventLog -LogName "Microsoft-Windows-DSC/Operational" -Source "xDSCFirewall" -ErrorAction SilentlyContinue
    Write-EventLog -LogName "Microsoft-Windows-DSC/Operational" -Source "xDSCFirewall" -EventId 3001 -EntryType Information -Message "Firewall zone $zone was disabled"

  }
  else
  {
    return $false
  }

  #Include this line if the resource requires a system reboot.
  #$global:DSCMachineStatus = 1


}


function Test-TargetResource
{
  [CmdletBinding()]
  [OutputType([System.Boolean])]
  param
  (
    [Parameter(Mandatory = $true)][ValidateSet("Domain","Private","Public")]
    [System.String]
    $Zone,

    [Parameter(Mandatory = $true)][ValidateSet("Present","Absent")]
    [System.String]
    $Ensure,

    [Parameter()][ValidateSet("True","False","NotConfigured")]
    [System.String]$LogBlocked = "False",

    [Parameter()][ValidateSet("True","False","NotConfigured")]
    [System.String]$LogAllowed = "False",

    [Parameter()][ValidateSet("True","False","NotConfigured")]
    [System.String]$LogIgnored = "NotConfigured",

    [Parameter()]
    [System.String]$LogMaxSizeKilobytes = "4096",

    [Parameter()][ValidateSet("Allow","Block","NotConfigured")]
    [System.String]$DefaultInboundAction = "NotConfigured",

    [Parameter()][ValidateSet("Allow","Block","NotConfigured")]
    [System.String]$DefaultOutboundAction = "NotConfigured"
  )

  $firewall = Get-NetFirewallProfile $Zone | Set-NetFirewallProfile -Enabled True -LogAllowed $LogAllowed -LogBlocked $LogBlocked -LogIgnored $LogIgnored -LogMaxSizeKilobytes $LogMaxSizeKilobytes -DefaultInboundAction $DefaultInboundAction -DefaultOutboundAction $DefaultOutboundAction

  if ($Ensure -eq 'Present')
  {
    if ($firewall.Enabled -eq $true)
    {
      return $true
    }
    else
    {
      return $false
    }
  }
  elseif ($Ensure -eq 'Absent')
  {
    if ($firewall.Enabled -eq $false)
    {
      return $true
    }
    else
    {
      return $false
    }
  }
      # Firewall Default Actions
    if ($DefaultInboundAction -eq $firewall.DefaultInboundAction) {
        Write-Verbose "No Action required! DefaultInboundAction is already set to $DefaultInboundAction"
        $result = $true
    } else {
        Write-Verbose "Action required! DefaultInboundAction is not set to $DefaultInboundAction ($($firewall.DefaultInboundAction))"
        $result = $false
    }     

    if ($DefaultOutboundAction -eq $firewall.DefaultOutboundAction) {
        Write-Verbose "No Action required! DefaultOutboundAction is already set to $DefaultOutboundAction"
        $result = $true
    } else {
        Write-Verbose "Action required! DefaultOutboundAction is not set to $DefaultOutboundAction ($($firewall.DefaultOutboundAction))"
        $result = $false
    }     

    # Check Firewall Log Configuration
    if ($LogAllowed -eq $firewall.LogAllowed) {
        Write-Verbose "No Action required! LogAllowed is already set to $LogAllowed"
        $result = $true
    } else {
        Write-Verbose "Action required! LogAllowed is not set to $LogAllowed ($($firewall.LogAllowed))"
        $result = $false
    }     
     
    if ($LogBlocked -eq $firewall.LogBlocked) {
        Write-Verbose "No Action required! LogBlocked is already set to $LogBlocked"
        $result = $true
    } else {
        Write-Verbose "Action required! LogBlocked is not set to $LogBlocked ($($firewall.LogBlocked))"
        $result = $false
    }        

    if ($LogIgnored -eq $firewall.LogIgnored) {
        Write-Verbose "No Action required! LogIgnored is already set to $LogIgnored" 
        $result = $true
    } else {
        Write-Verbose "Action required! LogIgnored is not set to $LogIgnored ($($firewall.LogIgnored))"
        $result = $false
    }     

    if ($LogMaxSizeKilobytes -eq $firewall.LogMaxSizeKilobytes) {
        Write-Verbose "No Action required! LogMaxSizeKilobytes is already set to $LogMaxSizeKilobytes"
        $result = $true
    } else {
        Write-Verbose "Action required! LogMaxSizeKilobytes is not set to $LogMaxSizeKilobytes ($($firewall.LogMaxSizeKilobytes))"
        $result = $false
    }     
}


Export-ModuleMember -Function *-TargetResource