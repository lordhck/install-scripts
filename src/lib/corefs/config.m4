build_config() {
    status "Writing system configuration"

    write_file "$ROOT/etc/hostname" <<'EOT'
core
EOT

    write_file "$ROOT/etc/hosts" <<'EOT'
127.0.0.1 localhost
127.0.1.1 core
::1 localhost
EOT

    write_file "$ROOT/etc/passwd" <<'EOT'
root:x:0:0:root:/root:/bin/bash
EOT

    write_file "$ROOT/etc/group" <<'EOT'
root:x:0:
bin:x:1:
daemon:x:2:
sys:x:3:
tty:x:5:
wheel:x:10:
users:x:100:
EOT

    write_file "$ROOT/etc/shadow" 600 <<'EOT'
root::0:0:99999:7:::
EOT

    write_file "$ROOT/etc/fstab" <<'EOT'
proc     /proc     proc     defaults               0 0
sysfs    /sys      sysfs    defaults               0 0
devtmpfs /dev      devtmpfs defaults               0 0
devpts   /dev/pts  devpts   gid=5,mode=620         0 0
tmpfs    /dev/shm  tmpfs    mode=1777,nosuid,nodev 0 0
tmpfs    /run      tmpfs    defaults               0 0
EOT

    # /dev/pts and /dev/shm only exist once devtmpfs is mounted.
    # devtmpfs has no /dev/fd, which bash needs for <(...).
    write_file "$ROOT/etc/inittab" <<'EOT'
::sysinit:/bin/mount /dev
::sysinit:/bin/mkdir -p /dev/pts /dev/shm
::sysinit:/bin/ln -s /proc/self/fd /dev/fd
::sysinit:/bin/mount -a
::sysinit:/bin/hostname -F /etc/hostname
::sysinit:/sbin/syslogd
::sysinit:/sbin/klogd
::sysinit:/bin/sh -c 'xargs modprobe -a < /etc/modules'
::sysinit:/sbin/ifup -a
::sysinit:/bin/sh -c '[ -e /etc/keymap.bmap.gz ] && zcat /etc/keymap.bmap.gz | loadkmap'
ttyS0::respawn:/sbin/getty -L -I '\033[H\033[2J' 115200 ttyS0 vt100
tty1::respawn:/sbin/getty 38400 tty1
::shutdown:/sbin/killall5 -15
::shutdown:/bin/sleep 1
::shutdown:/sbin/swapoff -a
::shutdown:/bin/umount -a -r
EOT

    write_file "$ROOT/etc/network/interfaces" <<'EOT'
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOT

    write_file "$ROOT/etc/profile" <<'EOT'
export PATH=/usr/sbin:/usr/bin
umask 022
PS1='\u@\h:\w\$ '
EOT

    write_file "$ROOT/etc/shells" <<'EOT'
/bin/sh
/bin/ash
/bin/bash
EOT

    write_file "$ROOT/etc/issue" <<'EOT'
Core Linux 0.1.0 \n \l

EOT

    write_file "$ROOT/etc/motd" <<'EOT'
Welcome to Core Linux.
EOT

    ok
}
