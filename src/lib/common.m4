if [[ -t 1 ]]; then
    RED=$'\e[31m' GREEN=$'\e[32m' YELLOW=$'\e[33m'
    BOLD=$'\e[1m' DIM=$'\e[2m' RESET=$'\e[0m' CR=$'\r'
else
    RED='' GREEN='' YELLOW='' BOLD='' DIM='' RESET='' CR=''
fi

STEP=''

msg() { printf '\n%s==> %s%s\n' "$BOLD" "$*" "$RESET"; }

# The pending line is redrawn by ok/die. Without a terminal it is
# skipped, so logs only get the final result.
status() {
    STEP="$*"
    [[ -n "$CR" ]] && printf '[    ] %s' "$STEP"
    return 0
}

ok() {
    printf '%s[%s OK %s] %s' "$CR" "$GREEN" "$RESET" "$STEP"
    [[ -n "${1:-}" ]] && printf ' %s(%s)%s' "$DIM" "$1" "$RESET"
    printf '\n'
    STEP=''
}

warn() {
    [[ -n "$STEP" && -n "$CR" ]] && printf '\r\e[K'
    printf '[%sWARN%s] %s\n' "$YELLOW" "$RESET" "$*" >&2
    [[ -n "$STEP" && -n "$CR" ]] && printf '[    ] %s' "$STEP"
    return 0
}

# Inside a step, the step is the title and every argument a detail line.
die() {
    local title="${STEP:-${1:-}}" line

    [[ -n "$STEP" ]] || shift
    printf '%s[%sFAIL%s] %s\n' "$CR" "$RED" "$RESET" "$title" >&2

    # A pipe, not <(...): that needs /dev/fd, which a bare chroot lacks.
    printf '%s\n' "$@" | while IFS= read -r line; do
        [[ -n "$line" ]] && printf '\t%s-> %s%s\n' "$DIM" "$line" "$RESET" >&2
    done

    exit 1
}

mkd() {
    local dir="$1" mode="${2:-755}"

    mkdir -p "$dir" || die "failed to create '$dir'"
    chmod "$mode" "$dir" || die "failed to chmod '$dir'"
}

lns() {
    local target="$1" link="$2"

    [[ -e "$link" && ! -L "$link" ]] && die "refusing to replace '$link'"
    ln -sfn "$target" "$link" || die "failed to link '$link'"
}

write_file() {
    local file="$1" mode="${2:-644}"

    mkdir -p "$(dirname "$file")" || die "failed to create parent directory"
    cat > "$file" || die "failed to write '$file'"
    chmod "$mode" "$file" || die "failed to chmod '$file'"
}
