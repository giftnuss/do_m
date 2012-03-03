#!perl -w
; use strict
; use Test::More tests => 3
; use Template::Magic

; our ( $tm
      , $tm2
      , $tm3
      , $tm4
      , $tmp2
      , $tmp3
      , $tmp4
      , $scalar_test
      , $content
      , $content2
      , $content3
      , $content4
      )
; $tm = new Template::Magic
; $scalar_test = 'SCALAR'
; $content = $tm->output('t/template_test_01')
; is ( $$content
     , "text from template SCALAR, text from included_test_01 with SCALAR, text from included_test_02 with SCALAR."
     )

; $tm3 = new Template::Magic
             zone_handlers=>'INCLUDE_TEXT'
; $tmp3 = 'text from template {scalar_test}, {INCLUDE_TEXT t/text_file}'
; $content3 = $tm3->output(\$tmp3);
; is ( $$content3
     , 'text from template SCALAR, text from file'
     )



; $tm4 = new Template::Magic
; $tmp4 = 'text from template {scalar_test}, {include_temp}'
; $content4 = $tm4->output(\$tmp4);
; is ( $$content4
     , 'text from template SCALAR, text from file'
     )

; sub include_temp
   { my ($z) = @_
   ; return $z->include_template('t/text_file')
   }
