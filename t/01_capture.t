#!perl -w
; use strict
; use Test::More tests => 4


; use IO::Util qw(capture)

; sub print_something
   { print shift()
   }
   
; my $out = capture { print_something('a'); print_something('b')}
; is ( $$out
     , 'ab'
     )
     
; select STDERR

; $out = capture { print_something('c'); print_something('d')} \*STDERR
; is ( $$out
     , 'cd'
     )

; select STDOUT


; { package test_tie
  ; use Tie::Handle
  ; our @ISA = qw(Tie::StdHandle)

  ; sub PRINT
     { my $s = shift
     }
  }

; tie *STDOUT, 'test_tie'

; $out = capture { print_something('e'); print_something('f')}
; ok (  ($$out eq 'ef')
     && (ref(tied *STDOUT) eq 'test_tie')
     )
; untie *STDOUT

; $, = '*'
; $\ = '#'

; $out = capture { print 'X', 'Y'
                 ; printf '<%6s>', "a"
                 ; print_something('Z');
                 }
; is( $$out
    , 'X*Y#<     a>Z#'
    )




