#!perl -w
; use strict
; use Test::More tests => 1
; use Template::Magic

; our ( $tm
      , $scalar_test
      , $content
      )
; $tm = new  Template::Magic
; $scalar_test = 'SCALAR'
; $content = $tm->output('t/template_test_02')
; is ( $$content
     , 'text from template SCALAR, end text.'
     )
