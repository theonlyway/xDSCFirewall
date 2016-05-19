function Get-TargetResource
{
  [CmdletBinding()]
  [OutputType([System.Collections.Hashtable])]
  param
  (
    [Parameter(Mandatory = $true)]
    [System.String]
    $Zone
  )
  $firewall = Get-NetFirewallProfile $Zone | select enabled

  if ($firewall.Enabled -eq $false) {
    return @{
      Ensure = "Absent";
      Zone = $Zone
    }
  }
  else
  {
    return @{
      Ensure = "Present";
      Zone = $Zone
    }
  }
}


function Set-TargetResource
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [System.String]
    $Zone,

    [ValidateSet("Present","Absent")]
    [System.String]
    $Ensure
  )

  if ($Ensure -eq "Present")
  {
    $EnableFW = Get-NetFirewallProfile $Zone | Set-NetFirewallProfile -Enabled True
    New-EventLog -LogName "Microsoft-Windows-DSC/Operational" -Source "xDSCFirewall" -ErrorAction SilentlyContinue
    Write-EventLog -LogName "Microsoft-Windows-DSC/Operational" -Source "xDSCFirewall" -EventId 3001 -EntryType Information -Message "Firewall zone $zone was enabled"
  }
  elseif ($Ensure -eq "Absent")
  {
    $DisableFW = Get-NetFirewallProfile $Zone | Set-NetFirewallProfile -Enabled False
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
    [Parameter(Mandatory = $true)]
    [System.String]
    $Zone,

    [ValidateSet("Present","Absent")]
    [System.String]
    $Ensure
  )

  $firewall = Get-NetFirewallProfile $Zone | select enabled

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
}


Export-ModuleMember -Function *-TargetResource