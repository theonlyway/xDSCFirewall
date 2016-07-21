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

**DefaultInboundAction**

- Allow - Sets the default inbound action to allowed
- Block - Sets the default inbound action to blocked
- NotConfigured - Sets the default inbound action to not configured
	- This is the default value

**DefaultOutboundAction**

- Allow - Sets the default outbound action to allowed
- Block - Sets the default outbound action to blocked
- NotConfigured - Sets the default outbound action to not configured
	- This is the default value

**LogAllowed**

- True - Tells the Firewall to log traffic that gets allowed
- False - Tells the firewall not to log traffic that gets allowed
	- This is the default value
- NotConfigured - Sets LogAllowed to not configured state where it doesn't log traffic

**LogIgnored**

- True - Tells the Firewall to log traffic that gets ignored
- False - Tells the firewall not to log traffic that gets ignored
- NotConfigured - Sets LogAllowed to not configured state where it doesn't log traffic
	- This is the default value

**LogBlocked**

- True - Tells the Firewall to log traffic that gets blocked
- False - Tells the firewall not to log traffic that gets blocked
	- This is the default value
- NotConfigured - Sets LogAllowed to not configured state where it doesn't log traffic

**LogMaxSizeKilobytes**

- 4096 - This is the default value in Kilobytes 


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

# Versions

## 1.3
Merged in requested changes from heoelri adding the following non-mandatory parameters

- LogAllowed
- LogIgnored
- LogBlocked
- LogMaxSizeKilobytes
- DefaultInboundAction
- DefaultOutboundAction

## 1.0
Basic DSC module to enable Firewall profiles