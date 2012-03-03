#!perl -w

; use strict
; use Test::More tests => 1
; use Template::Magic

; our ( $tm
      , $scalar_test
      , $empty
      , $content
      , $expected
      , $tmp
      )
      
; $tm = new Template::Magic
            zone_handlers => 'TRACE_DELETIONS'
            
; $scalar_test = 'SCALAR'
; $empty = ''

; $tmp = 'text {empty} from template {scalar_test} placeholder {/scalar_test},{simulated_area} simulated text {scalar_test} {/simulated_area} end text.';

; $expected = << '__EOS__';
text <<empty found but empty>> from template SCALAR,<<simulated_area not found>> end text.
__EOS__

; $content = $tm->output(\$tmp)
; is( $$content."\n"
    , $expected
    )
