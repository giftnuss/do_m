#!perl -w
; use strict
; use warnings
; use Test::More tests => 5
#; use Data::Dumper


; my $o = MyTest->new()

; is( $o->one => 2 )
; is( $o->two => 2 )
; is_deeply( scalar $o->group1 => { one => 20
                                  , two => 30
                                  }
           )

; is( $o->group1->{one} => 20 )
; is( $o->group1->{two} => 30 )
 
; package MyTest

; use Class::constr

; use Object::props
   { name    => ['one','two']
   , default => 2
   }
  
; use Object::groups
   { name    => 'group1'
   , default => { one => 20
                , two => 30
                }
   }













