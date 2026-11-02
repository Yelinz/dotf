# Failing OS/RAID disk: replacement runbook (2026-11)

The disk `WD3000F9YZ` serial **WD-WMC5D0D1ZXAJ** ("ZXAJ") is failing: reallocated
sectors went from 1 to 1905 between 2026-10-26 and 10-31, with 6 SMART self-test
errors. It holds the OS and **half of the RAID0 `/home`**, so if it dies, `/home`
dies with it.

Always identify disks by **serial**. `sdX` letters change between boots.

| Serial | Model | Role | by-id |
|---|---|---|---|
| WD-WMC5D0D1ZXAJ | WD3000F9YZ 3 TB | **FAILING**. EFI, `/`, `/var`, swap, `/tmp`, md0 member (part6) | `ata-WDC_WD3000F9YZ-09N20L1_WD-WMC5D0D1ZXAJ` |
| WD-WMC5D0D19TC3 | WD3000F9YZ 3 TB | healthy, md0 member (part1) | `ata-WDC_WD3000F9YZ-09N20L1_WD-WMC5D0D19TC3` |
| 14480DE691EF | Crucial MX100 512 GB | SSD: Docker root, all `*-conf` dirs (Immich DB too), main swap | `ata-Crucial_CT512MX100SSD1_14480DE691EF` |
| WD-WXM1EB634NC3 | WD Elements 1 TB (USB, NTFS) | restic backup repo + `sdc-rescue-20261102/` | `ata-WDC_WD10JMVW-11AJGS4_WD-WXM1EB634NC3` |

Partition layout of ZXAJ (GPT): p1 EFI 976M · p2 `/` 93.1G · p3 `/var` 37.3G · p4 swap 16G · p5 `/tmp` 2.8G · p6 linux_raid_member 2.6T.

## 0. State at shutdown (2026-11-02)

- All heavy containers were stopped with `docker stop`. Their restart policy is `unless-stopped`,
  so **they stay stopped after a reboot** until you run `docker compose up -d`.
- The `cross-seed-search.timer` user timer was stopped.
- Backups: the WD Elements restic repo had a snapshot from 22:30 that passed `restic check`, and
  a sample photo restore came back byte-identical. A final incremental ran after the
  services were stopped. Proton Drive holds 11 snapshots of the Immich library.
- `sdc-rescue-20261102/` on the WD Elements contains `/etc` (tar), dotfiles, the dpkg
  selections, the compose file, lsblk output and mdstat.
- The restic repo password is in `/mnt/ssd/conf/backrest-conf/config/config.json` (on the SSD,
  which is not the failing disk). **Also keep a copy in your password manager.**

## 1. Hardware

- The new disk must be **at least 3 TB** (≥ 3,000,592,982,016 bytes). Check that the capacity on the label is not smaller.
- Do not put it in the front bay (no airflow). ZXAJ can stay in the front bay for the
  few hours the clone takes.
- You need: a SystemRescue USB stick (it includes `ddrescue`, `mdadm`, `sgdisk`, `ntfs-3g`)
  and the WD Elements plugged in for the map file.

## 2. Clone (boot SystemRescue, NOT the installed OS)

```bash
# 2.1 Identify the disks. ZXAJ = old; the new disk's serial is whatever lsblk shows that isn't in the table above.
lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE
ls -l /dev/disk/by-id/ | grep -v part

OLD=/dev/disk/by-id/ata-WDC_WD3000F9YZ-09N20L1_WD-WMC5D0D1ZXAJ
NEW=/dev/disk/by-id/ata-PUT_NEW_DISK_ID_HERE          # copy exactly from the ls output
readlink -f "$OLD" "$NEW"                             # must print two DIFFERENT /dev/sdX
blockdev --getsize64 "$OLD" "$NEW"                    # NEW must be >= OLD

# 2.2 Make sure nothing in the live system is using the disks
cat /proc/mdstat                     # if an md device is listed:  mdadm --stop /dev/mdNNN
swapoff -a
mount | grep -E "$(readlink -f $OLD)|$(readlink -f $NEW)"   # must print nothing

# 2.3 Mount the WD Elements for the map file (931.5G NTFS partition)
mkdir -p /mnt/bk
mount -t ntfs-3g /dev/disk/by-id/ata-WDC_WD10JMVW-11AJGS4_WD-WXM1EB634NC3-part1 /mnt/bk
MAP=/mnt/bk/sdc-rescue-20261102/zxaj.map

# 2.4 Pass 1: copy everything that reads easily, skip bad areas (hours)
ddrescue -f -n "$OLD" "$NEW" "$MAP"
# 2.5 Pass 2: go back and retry the bad areas 3 times
ddrescue -f -d -r3 "$OLD" "$NEW" "$MAP"

# If it gets interrupted (or the old disk drops out), rerun the same command. The map makes it resume.

# 2.6 Result. "bad-sector" / "non-tried" should ideally be 0 B.
ddrescuelog -t "$MAP"
```

```bash
# 2.7 New disk bigger than 3 TB? Move the GPT backup header to the real end of the disk.
sgdisk -e "$NEW"
partprobe "$NEW"
```

## 3. Verify BEFORE rebooting (still in SystemRescue)

```bash
# 3.1 Physically disconnect ZXAJ now (power off first: poweroff, unplug, boot SystemRescue again).
#     The clone has identical UUIDs. With both disks connected, the system can mount the wrong one.

# 3.2 File system checks on the clone
NEW=/dev/disk/by-id/ata-PUT_NEW_DISK_ID_HERE
e2fsck -f "$NEW-part2"     # /
e2fsck -f "$NEW-part3"     # /var
e2fsck -f "$NEW-part5"     # /tmp
fsck.vfat -n "$NEW-part1"  # EFI (read-only check)

# 3.3 Assemble the RAID from the healthy disk + the clone, check /home
mdadm --assemble /dev/md0 /dev/disk/by-id/ata-WDC_WD3000F9YZ-09N20L1_WD-WMC5D0D19TC3-part1 "$NEW-part6"
cat /proc/mdstat           # md0 : active raid0, 2 devices
e2fsck -f /dev/md0         # /home. This takes a while on 5.3 TB.
mdadm --stop /dev/md0
```

If e2fsck asks a lot of questions, answer `y`, or run `e2fsck -f -y`.

## 4. Boot the installed system from the new disk

1. Boot normally. In the firmware boot menu, choose the new disk if it isn't picked automatically.
   The EFI partition was cloned, so the "debian" entry should work. If it doesn't, see 6.
2. Check:
   ```bash
   lsblk -o NAME,SIZE,SERIAL,MOUNTPOINTS
   cat /proc/mdstat
   df -h / /var /home /mnt/ssd
   ```
3. Start everything again:
   ```bash
   cd /home/media/tools && docker compose up -d
   systemctl --user start cross-seed-search.timer
   ```
4. Fix the port-forward script. It still points at the old router subnet:
   ```bash
   sudo sed -i 's|192.168.178.67|192.168.1.2|' /usr/local/bin/proton-portforward.sh
   ```
5. Run a backrest backup, then turn on SMART tests for the new disk (smartd already does DEVICESCAN).

## 5. If ddrescue reported bad sectors

The affected files may be corrupted. Photos and configs can be restored from the WD Elements
restic repo (backrest UI → Restore, or ask Claude to compare checksums against the
snapshot). Media in `/home` can be downloaded again.

## 6. Fallback: ZXAJ dies before or during the clone

Use whatever ddrescue copied, even if partial: `/` and `/var` are at the start of the disk and
get copied first. If the md0 part is unrecoverable:

1. Install Debian 13 on the new disk, or keep the partially cloned OS if it boots.
2. The SSD is untouched: mount UUID `3b4e4d59-6856-409f-84ae-753bda6152e4` at `/mnt/ssd`.
   Docker root and every `*-conf` dir live there.
3. Recreate `/home` on new disk + 19TC3 (THIS ERASES BOTH; only do it when the old array is gone):
   `mdadm --create /dev/md0 --level=0 --raid-devices=2 <19TC3>-part1 <NEW>-partN && mkfs.ext4 /dev/md0`
4. Restore from restic (password: backrest config on the SSD). The repo is the root of the
   WD Elements drive. Snapshot paths are as backrest saw them: `/userdata/immich-images` = `/home/media/Bilder`,
   `/userdata/container-confs` = `/home/media/tools`.
   ```bash
   export RESTIC_REPOSITORY=/media/media/Elements      # wherever the Elements is mounted
   restic snapshots --latest 3                          # asks for the password
   restic restore latest --target /home/restore         # creates /home/restore/userdata/...
   rsync -a /home/restore/userdata/immich-images/ /home/media/Bilder/
   rsync -a /home/restore/userdata/container-confs/ /home/media/tools/
   ```
   The Immich DB is on the SSD. If that were lost too, `Bilder/backups/immich-db-backup-*.sql.gz`
   (nightly dump, included in the backup) restores it.
5. Restore `/etc` bits from `sdc-rescue-20261102/etc.tgz` and the files in this repo (`homelab/server/etc`).
6. Recreate the `tools/*-conf -> /mnt/ssd/conf/*` symlinks.
