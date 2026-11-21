build_filesystem() {
    local dir

    status "Creating filesystem"

    # Written first: corefs only wipes a rootfs that has it, so even
    # a failed build can be cleaned by the next one.
    write_file "$ROOT/etc/os-release" <<'EOT'
NAME="Core Linux"
ID=core
PRETTY_NAME="Core Linux"
VERSION="0.1.0"
VERSION_ID="0.1.0"
EOT

    for dir in boot dev etc home mnt opt proc run srv sys \
               usr/{bin,include,lib,libexec,sbin,share} \
               var/{cache,lib,log,spool}; do
        mkd "$ROOT/$dir"
    done

    mkd "$ROOT/root"     700
    mkd "$ROOT/tmp"      1777
    mkd "$ROOT/var/tmp"  1777
    mkd "$ROOT/run/lock"

    # init needs a console before devtmpfs is mounted.
    mknod -m 600 "$ROOT/dev/console" c 5 1 || die "failed to create /dev/console"

    ok
}
