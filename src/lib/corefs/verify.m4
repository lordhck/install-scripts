# scanelf reads ELF headers only, so nothing from the rootfs is executed.
# Only usr/ is scanned; bin, sbin and lib are symlinks into it.
verify_elf() {
    local file interp needed lib missing=0
    local -a libs

    command -v scanelf >/dev/null || die "scanelf not found"

    status "Checking ELF dependencies"

    while IFS=';' read -r file interp needed; do
        if [[ -n "$interp" && ! -e "$ROOT$interp" ]]; then
            warn "${file#"$ROOT"}: missing interpreter $interp"
            missing=1
        fi

        IFS=',' read -ra libs <<< "$needed"
        for lib in "${libs[@]}"; do
            [[ -e "$ROOT/usr/lib/$lib" ]] && continue
            warn "${file#"$ROOT"}: missing library $lib"
            missing=1
        done
    done < <(scanelf -RBF '%F;%i;%n' "$ROOT/usr")

    ((missing == 0)) || die "unresolved ELF dependencies"

    ok
}
