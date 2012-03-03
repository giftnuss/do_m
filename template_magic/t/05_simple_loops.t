#!perl -w
; use strict 
; use Test::More tests => 1
; use  Template::Magic
; our ( $tm
      , $content
      , $tmp
      , $my_loop
      )

; $tm = new Template::Magic
; $tmp = 'A loop:{my_loop}|Date: {date} - Operation: {operation}{/my_loop}|'

; $my_loop = [ { date      => '8-2-02'
               , operation => 'purchase'
               }
             , { date      => '9-3-02'
               , operation => 'payment'
               }
             ]

; $content = $tm->output(\$tmp);
; is ( $$content
     , 'A loop:|Date: 8-2-02 - Operation: purchase|Date: 9-3-02 - Operation: payment|'
     )
