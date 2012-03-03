#!perl -w

; use strict
; use Test::More tests => 1
; use Template::Magic

; my %hash1 = ( var1 => 1
              , var2 => 2
              )
; my %hash2 = ( var1 => 3
              , var2 => 4
              )

; our $mt = new Template::Magic
                lookups => \%hash1
               

; my $out = ${$mt->output('t/25_tmpl')}

; $mt = new Template::Magic
            lookups => \%hash2


; $out .= ${$mt->output('t/25_tmpl')}

; is( $out
    , 'text 1, text 2. text 3, text 4. '
    )
