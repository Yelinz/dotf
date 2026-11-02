systemd to /etc/systemd/system

## server/
Sanitized config of the media/homelab server (Debian 13). Secrets are not in git: copy
`server/compose/.env.example` to `.env`; the Deluge password for `bin/proton-portforward.sh`
goes in `/etc/proton-portforward.env`. Per-app `*-conf` dirs live on the SSD and are not tracked.
Disk-failure runbook: [server/RECOVERY.md](server/RECOVERY.md).
