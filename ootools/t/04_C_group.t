#!perl -w

; use strict
; use Test::More tests => 10
; use strict

; my $h = BaseClass->group1

; is( keys %$h
    , 2
    )

; $h = SubClass->group1

; is( keys %$h
    , 3
    )

; is( $h->{one}
    , 4
    )

; BaseClass->group1( one => 1
                   , two => 2
                   )
                   
; my @p =  BaseClass->group1
; is( scalar @p
    , 2
    )
; is( BaseClass->group1->{one}
      + $BaseClass::group1{one}
    , 2
    )
; is( BaseClass->one * BaseClass->two
    , 2
    )

; SubClass->one = 1
; SubClass->three = 3
; SubClass->two = 2
; @p =  SubClass->group1

; is( scalar @p
    , 3
    )

; my $str = join '', @p
; ok(    $str =~ /one/
      && $str =~ /two/
      && $str =~ /three/
    )

; @p =  Other->group1
; is( scalar @p
    , 0
    )

; Other->two = 2

; my $o = Other->group1
       
; is( $o->{two}
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
               
; use Class::group  name => 'group1'
                  , props => \@props
                   
                   

                                 
; package SubClass
; use base 'BaseClass'

; use Class::group (  name => 'group1'
                   ,  props => [ { name    => [ "one"
                                              , "three"
                                              ]
                                 , default => 4
                                 }
                               ]
                   )


; package Other
; use base 'SubClass'

; use Class::group ( name => 'group1'
                   , props => [ 'four' ]
                   )




