; use strict

; package one
; sub OH_init { print 'one' }

; package two

; use CGI::Builder
  qw| one
    |
; sub OH_init { print 'two' }

; package simpletwo
; sub OH_init { print 'simpletwo' }

; package three
; use CGI::Builder
  qw| one
      simpletwo
    |

; INIT
   { three->overrun_handler_map('init' => [ qw(three simpletwo one) ] )
   ;
   }

; sub OH_init { print 'three' }


; package main

; use Test::More tests => 11


; is( $two::ISA[0]
    , 'one'
    )

; is( $two::ISA[1]
    , 'CGI::Builder'
    )

; is( two->overrun_handler_map('init')->[0]
    , 'one'
    )

; is( two->overrun_handler_map('init')->[1]
    , 'two'
    )
; use IO::Util qw|capture|

; is( ${+ capture{ two->CGI::Builder::_::exec('init') }}
    , 'onetwo'
    )

; use IO::Util qw|capture|
; my $o
; is( ${+ capture{ $o = two->new() } }
    , 'onetwo'
    )

### overtwo

; is( three->overrun_handler_map('init')->[0]
    , 'three'
    )

; is( three->overrun_handler_map('init')->[1]
    , 'simpletwo'
    )
; is( three->overrun_handler_map('init')->[2]
    , 'one'
    )
; use IO::Util qw|capture|

; is( ${+ capture{ three->CGI::Builder::_::exec('init') }}
    , 'threesimpletwoone'
    )

; is( ${+ capture{ $o = three->new() } }
    , 'threesimpletwoone'
    )








































