#!perl -w
; use strict
; use Test::More tests => 2


; use IO::Util qw(capture)

; sub print_something
   { print shift()
   }
   
; my $out = capture { print_something('a'); print_something('b')}
; is ( $$out
     , 'ab'
     )
     
; select STDERR

; $out = capture { print_something('c'); print_something('d')} STDERR
; is ( $$out
     , 'cd'
     )
