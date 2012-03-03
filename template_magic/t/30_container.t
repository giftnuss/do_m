#!perl -w

; use strict
; use Test::More tests => 4
; use Template::Magic


      
; my $container1 = 'start {INCLUDE_TEMPLATE} end'
; my $tmp1 = 'included template'
; my $tmp2 = 'included template 2'



; my $tm = Template::Magic->new( container_template => \$container1 )

   
; my $content = $tm->output(\$tmp1)
; is ( $$content
     , 'start included template end'
     )
; my $container2 = 'start {INCLUDE_TEMPLATE} end 2'

; $content = $tm->noutput( template           => \$tmp2
                         , container_template => \$container2)
; is ( $$content
     , 'start included template 2 end 2'
     )
; $content = $tm->output(\$tmp1)
; is ( $$content
     , 'start included template end'
     )

; $content = $tm->output(\$tmp2)
; is ( $$content
     , 'start included template 2 end'
     )


