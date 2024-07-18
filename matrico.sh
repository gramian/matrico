#! /bin/sh

#|
exec csi -R matrico -q "$0" "$@"
|#

(print "\033]0;matrico\007") ; set window title
