fetch_packages() {
    local -a files=()
    local out

    status "Fetching packages"

    mkdir -p "$CACHE/packages" || die "failed to create package cache"

    out="$(apk update 2>&1)" || die "failed to update package indexes" "$out"
    out="$(apk fetch --recursive --output "$CACHE/packages" "${PACKAGES[@]}" 2>&1)" \
        || die "failed to fetch packages" "$out"

    files=("$CACHE/packages"/*.apk)
    ok "${#files[@]} packages"
}

# apk-tools 2.x has no 'apk extract'; a v2 .apk is a concatenated
# gzip tar stream, so GNU tar can unpack it directly. Skip the apk
# metadata entries and keep the merged-usr directory symlinks intact.
extract_packages() {
    local package

    status "Extracting packages"

    for package in "$CACHE/packages"/*.apk; do
        [[ -f "$package" ]] || die "no packages found"

        tar -xzf "$package" -C "$ROOT" \
            --numeric-owner \
            --keep-directory-symlink \
            --warning=no-unknown-keyword \
            --anchored \
            --exclude='.PKGINFO' \
            --exclude='.SIGN.*' \
            --exclude='.pre-*' \
            --exclude='.post-*' \
            --exclude='.trigger' \
            || die "failed to extract $(basename "$package")"
    done

    ok
}

# Alpine creates the applet links in busybox's post-install script,
# which extract_packages skips. Recreate them as relative links.
install_busybox_applets() {
    local -a applets=()
    local applet dir target

    status "Installing busybox applets"

    [[ -x "$ROOT/usr/bin/busybox" ]] || die "busybox binary not found"

    mapfile -t applets < <(chroot "$ROOT" /usr/bin/busybox --list-full) \
        || die "failed to list busybox applets"
    ((${#applets[@]})) || die "busybox reported no applets"

    for applet in "${applets[@]}"; do
        case "$applet" in
            bin/*|usr/bin/*)   dir=usr/bin;  target=busybox ;;
            sbin/*|usr/sbin/*) dir=usr/sbin; target=../bin/busybox ;;
            *) warn "skipping applet with unknown path: $applet"; continue ;;
        esac

        applet="${applet##*/}"
        [[ "$applet" == busybox ]] && continue
        [[ -e "$ROOT/$dir/$applet" || -L "$ROOT/$dir/$applet" ]] && continue

        lns "$target" "$ROOT/$dir/$applet"
    done

    ok "${#applets[@]} applets"
}

build_packages() {
    fetch_packages
    extract_packages
    install_busybox_applets
}
