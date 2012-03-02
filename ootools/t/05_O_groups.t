#!perl -w

; use strict
; use Test::More tests => 10
; use strict
; use Data::Dumper

; my $BCo = BaseClass->new

; my $SCo = SubClass->new

; my $Oo = Other->new

; my $h = $BCo->group1

; is( keys %$h
    , 2
    )

; $h = $SCo->group1

; is( keys %$h
    , 3
    )
    

; is( $$h{one}
    , 4
    )

; $BCo->group1( one => 1
              , two => 2
              )

; my @p =  $BCo->group1
; is( scalar @p
    , 2
    )
; is( $BCo->group1->{one}
      + $BCo->{group1}{one}
    , 2
    )
; is( $BCo->one * $BCo->two
    , 2
    )

; $SCo->one = 1
; $SCo->three = 3
; $SCo->two = 2
; @p =  $SCo->group1

; is( scalar @p
    , 3
    )

; my $str = join '', @p
; ok(    $str =~ /one/
      && $str =~ /two/
      && $str =~ /three/
    )

; @p =  $Oo->group1
; is( scalar @p
    , 4
    )

; $Oo->two = 2

; my $o = $Oo->group1

; is( $$o{two}
    , 2
    )

   
; package BaseClass

; use Class::constr

; our @props
; BEGIN
   { @props = { name => [ "one"
                        , "two"
                        ]
              , default => 2
              }
              
   }
               
; use Object::groups { name => 'group1'
                     , props => \@props
                     }
                   

                                 
; package SubClass
; use base 'BaseClass'

; use Object::groups {  name => 'group1'
                     ,  props => [ { name    => [ "one"
                                                , "three"
                                                ]
                                   , default => 4
                                   }
                                 ]
                     }


; package Other
; use base 'SubClass'

; use Object::groups { name => 'group1'
                     , props => [ 'four' ]
                     }
                  



