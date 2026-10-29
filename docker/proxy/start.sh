#!/bin/sh
# Writes the tinyproxy config for this mode and runs it in the foreground.
conf=/etc/tinyproxy/sandbox.conf
cat > "$conf" <<CONF
Port 8888
Listen 0.0.0.0
Timeout 600
MaxClients 200
LogLevel Notice
CONF
if [ "$FILTER" = 1 ]; then
  touch /etc/tinyproxy/allow
  cat >> "$conf" <<CONF
ConnectPort 443
Filter "/etc/tinyproxy/allow"
FilterType fnmatch
FilterDefaultDeny Yes
CONF
fi
exec tinyproxy -d -c "$conf"
