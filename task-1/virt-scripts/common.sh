#!/bin/sh

CODENAME=oreo
CNTFILE="$(pwd)/vm-cnt"
ISOPATH="$HOME/Documents/ISO"

addVM() {
      sh -c 'echo $(($(<"$CNTFILE")+1)) > "$CNTFILE"' 2>/dev/null
}

removeVM() {
      echo $(($(<"$CNTFILE")-1)) > "$CNTFILE"
}
