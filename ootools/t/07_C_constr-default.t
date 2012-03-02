#!perl -w
; use strict
; use warnings
; use Test::More tests => 13

; package My::Test1

; use Class::constr
   { default => { a => 2
                , b => 3
                }
   , no_strict => 1
   }


; package main
; my $o1 = My::Test1->new()
; is ( $$o1{a}, 2 )
; is ( $$o1{b}, 3 )


; package My::Test2

; use Class::constr
   { default => sub{ +{ a => 2
                      , b => 3
                      }
                   }
   , no_strict => 1
   }


; package main
; my $o2 = My::Test2->new()
; is ( $$o2{a}, 2 )
; is ( $$o2{b}, 3 )

; package My::Test3

; use Class::constr
   { default => 'def'
   , no_strict => 1
   }

; sub def
   { +{ a => 2
      , b => 3
      }
   }
   
; package main
; my $o3 = My::Test3->new()
; is ( $$o3{a}, 2 )
; is ( $$o3{b}, 3 )

; package My::Test4

; use Class::constr
   { default => sub{ +{ a => 2
                      , b => 3
                      }
                   }
   , no_strict => 1
   }


; package main
; my $o4 = My::Test2->new(a=>5)
; is ( $$o4{a}, 5 )
; is ( $$o4{b}, 3 )

# overwriting

; package My::Test5

; use Class::constr
   { default => { a => 2
                , b => 3
                }
   , no_strict => 1
   }
   
; use Class::constr
   { name    => 'copy_me'
   , default => { a => 4
                , b => 5
                , c => 5
                }
   , copy    => 1
   , no_strict => 1
   }
   
; package main
; my $o5 = My::Test5->new()
; is ( $$o5{a}, 2 )
; is ( $$o5{b}, 3 )

; my $o6 = $o5->copy_me(a=>8)
; is ( $$o6{a}, 8 )
; is ( $$o6{b}, 3 )
; is ( $$o6{c}, 5 )










