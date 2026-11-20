build_symlinks() {
    status "Creating symlinks"

    lns usr/bin  "$ROOT/bin"
    lns usr/sbin "$ROOT/sbin"
    lns usr/lib  "$ROOT/lib"

    lns ../run      "$ROOT/var/run"
    lns ../run/lock "$ROOT/var/lock"

    lns /proc/self/mounts "$ROOT/etc/mtab"

    ok
}
