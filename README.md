# xDSCFirewall #
## Overview ##

This custom resource either enables or disables the Public, Private or Domain windows firewall zones

### Parameters ###

**Ensure**

*Note: This is a required parameter*

- Present - Ensures a firewall zone is always enabled
- Absent - Ensures a firewall zone is always disabled

**Zone**

*Note: This is a required parameter*

- Define the zone you want enabled or disabled. Available firewall zones are Public, Private or Domain.

**Note:** Currently only supports one zone per config block

### Example ###

    Service WindowsFirewall
    {
    Name = "MPSSvc"
    StartupType = "Automatic"
    State = "Running"
    }
    xDSCFirewall DisablePublic
    {
      Ensure = "Absent"
      Zone = "Public"
      Dependson = "[Service]WindowsFirewall"
    }
    xDSCFirewall EnabledDomain
    {
      Ensure = "Present"
      Zone = "Domain"
      LogAllowed = "False"
      LogIgnored = "False"
      LogBlocked = "False"
      LogMaxSizeKilobytes = "4096"
      DefaultInboundAction = "Block"
      DefaultOutboundAction = "Allowed"
      Dependson = "[Service]WindowsFirewall"
    }
    xDSCFirewall EnabledPrivate
    {
      Ensure = "Present"
      Zone = "Private"
      Dependson = "[Service]WindowsFirewall"
    }
