#!perl -w
; use strict
; use warnings
; use Test::More tests => 7
#; use Data::Dumper

; BEGIN
   { use_ok 'Class::Util'
   ; Class::Util->import('blessed')
   }


; is blessed(bless {}, 'aclass'), 'aclass'
; is blessed(undef), undef
; is blessed(''), undef
; is blessed('something'), undef
; is blessed(\'something'), undef
; is blessed({}), undef
