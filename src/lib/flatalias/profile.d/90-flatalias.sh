#
# This file belongs to Flatalias.
#
# Load Flatalias' cached Flatpak aliases from $XDG_STATE_HOME/flatalias.profile,
# unless running in a non-interactive shell, or a shell not supporting aliases.
#

case "$-" in *i*) ;; *) return 0 ;; esac
command -v alias > /dev/null 2>&1 || return 0

if [ -f "${XDG_STATE_HOME:-${HOME:-$(cd ~ && pwd)}/.local/state}/flatalias.profile" ]; then
    . "${XDG_STATE_HOME:-${HOME:-$(cd ~ && pwd)}/.local/state}/flatalias.profile"
fi
