#!perl -w

; use strict
; use Test::More tests => 1
; use Template::Magic

; our ( $tm
      , $ident
      , $content
      )
; $tm = new Template::Magic
            zone_handlers => '_EVAL_' ;
; $ident = 'III'
; $content = $tm->output(\*DATA)
; is ( $$content
     , "text WWWWW text III\n"
     )

__DATA__
text {_EVAL_} 'W' x 5 {/_EVAL_} text {ident}
