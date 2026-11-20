KERNEL_PACKAGE=linux-virt
# The initramfs loads the disk modules, so /etc/modules only gets these.
BOOT_MODULES=(virtio_net af_packet)
KERNEL_MODULES=("${BOOT_MODULES[@]}" virtio_blk crc32c_generic ext4)

# The full module tree is ~28M, so only the modules listed above and
# their dependencies go into the rootfs.
build_kernel() {
    local -a packages=() files=()
    local -a tarflags=(--warning=no-unknown-keyword)
    local apk moddir dep module out

    status "Fetching kernel"

    out="$(apk fetch --output "$CACHE" "$KERNEL_PACKAGE" 2>&1)" \
        || die "failed to fetch $KERNEL_PACKAGE" "$out"

    packages=("$CACHE/$KERNEL_PACKAGE"-*.apk)
    apk="${packages[0]}"

    tar -xzf "$apk" -C "$ROOT" "${tarflags[@]}" boot/vmlinuz-virt \
        || die "failed to extract kernel"

    moddir="$(tar -tzf "$apk" "${tarflags[@]}" \
        | awk -F/ '!d && $1 == "lib" && $2 == "modules" && $3 {print "lib/modules/" $3; d=1}')"
    [[ -n "$moddir" ]] || die "no modules in $KERNEL_PACKAGE"

    dep="$(tar -xzOf "$apk" "${tarflags[@]}" "$moddir/modules.dep")" \
        || die "failed to read modules.dep"

    for module in "${KERNEL_MODULES[@]}"; do
        grep -q "/$module\.ko[^:]*:" <<< "$dep" || die "module '$module' not found"
    done

    # modules.dep lists each module's full dependency chain.
    mapfile -t files < <(
        awk -v want=" ${KERNEL_MODULES[*]} " '{
            sub(":", "", $1)
            name = $1; sub(/.*\//, "", name); sub(/\.ko.*/, "", name)
            if (index(want, " " name " ")) for (i = 1; i <= NF; i++) print $i
        }' <<< "$dep" | sort -u
    )

    tar -xzf "$apk" -C "$ROOT" "${tarflags[@]}" --keep-directory-symlink \
        "$moddir"/modules.{dep,alias,builtin,order} \
        "${files[@]/#/$moddir/}" \
        || die "failed to extract kernel modules"

    printf '%s\n' "${BOOT_MODULES[@]}" > "$ROOT/etc/modules" \
        || die "failed to write /etc/modules"

    ok "$(basename "$apk" .apk), ${#files[@]} modules"
}
