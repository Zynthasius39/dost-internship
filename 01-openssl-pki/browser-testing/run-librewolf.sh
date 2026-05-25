#!/bin/sh
# Bubblewrap Wrapper for Librewolf

BDIR=$(pwd)

mkdir -p $BDIR/librewolf-data $BDIR/Downloads

bwrap \
    --symlink usr/lib /lib \
    --symlink usr/lib64 /lib64 \
    --symlink usr/bin /bin \
    --symlink usr/bin /sbin \
    --ro-bind /usr/lib /usr/lib \
    --ro-bind /usr/lib64 /usr/lib64 \
    --ro-bind /usr/bin /usr/bin \
    --ro-bind /etc /etc \
    --ro-bind /usr/lib/librewolf /usr/lib/librewolf \
    --ro-bind /usr/share /usr/share \
    --dev /dev \
    --dev-bind /dev/dri /dev/dri \
    --proc /proc \
    --ro-bind /sys/dev/char /sys/dev/char \
    --ro-bind /sys/devices /sys/devices \
    --dir "$XDG_RUNTIME_DIR" \
    --ro-bind "$XDG_RUNTIME_DIR/wayland-1" "$XDG_RUNTIME_DIR/wayland-1" \
    --ro-bind "$XDG_RUNTIME_DIR/pipewire-0" "$XDG_RUNTIME_DIR/pipewire-0" \
    --ro-bind "$XDG_RUNTIME_DIR/pulse" "$XDG_RUNTIME_DIR/pulse" \
    --tmpfs /tmp \
    --dir $HOME/.cache \
    --bind $BDIR/librewolf-data $HOME/.librewolf \
    --bind $BDIR/Downloads $HOME/Downloads \
    /usr/bin/librewolf
