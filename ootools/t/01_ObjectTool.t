#!perl -w
; use strict
; use Test::More tests => 32


; common_test('BaseClass');
; common_test('SubClass');

; sub common_test
   {
   ; my ($class) = @_

   # 01 ############
   ; my $o1 = $class->new
   ; ok( ref $o1 eq "$class"
       , 'Object creation'
       )
   ; $o1->BpropA = 2
   ; $o1->BpropB = 3

   # 02 ############
   ; my $o2 = $class->new( BpropA => 25
                            , BpropB => 3
                            )
   ; is( $o2->BpropA * $o2->BpropB
       , 75
       , 'Passing new properties with new' )
   ; is( $o1->BpropA * $o1->BpropB
       , 6
       , 'Other object same test' )

   # 03 ############
   ; eval
      { my $o3 = $class->new( unknown => 10 )
      }
   ; ok( $@
       , 'Passing an unknow property'
       )
    
   # 04 ############
   ; is( $o1->Bdefault
       , 25
       , "Reading default"
       )

   # 05 ############
   ; $o1->Bvalid = 5
   ; is( $o1->Bvalid
       , 5
       , 'Writing an always valid property'
       )

   # 06 ############
   ; $o1->writeBprotA(5)
   ; is( $o1->BprotA
       , 5
       , "Writing protected property from class"
       )
       
   # 07 ############
   ; eval
      { $o1->BprotA = 10
      }
   ; ok( $@
       , 'Trying to write a protected property from outside'
       )

   # 08############
   ; $o1->writeBprotA(8)
   ; is( $o1->BprotA
       , 8
       , "Writing again protected property from class"
       )

   # 09 ############
   ; is( $o1->Bvalidat('aawwwbb')
       , 'aawwwbb'
       , 'Writing a valid value'
       )

   # 10 ############
   ; eval
      { $o1->Bvalidat = 10
      }
   ; ok( $@
       , 'Writing an invalid value'
       )
       
   # 11 ############
   ; is( $o1->Bvalidat('aawwwbb')
       , 'aawwwbb'
       , 'Writing again a valid value'
       )
       
   # 12 ############
   ; is( $o1->Bvalidat_default('aawwwbb')
       , 'aawwwbb'
       , 'Writing a valid value in a property with default'
       )

## 13 ############
   ; ok( (not $o1->Barr_namedA)
       , 'Default undef value'
       )

   ## 14 ############
   ; $o1->Bdefault = 56
   ; undef $o1->Bdefault
   ; is( $o1->Bdefault
       , 25
       , 'Reset to default'
       )

   ## 15 ############
   ; $o1->Bmod_input = 'abc'
   ; is( $o1->Bmod_input
       , 'ABC'
       , 'Modifying input'
       )

   }


; package BaseClass

; use Class::new

; use Object::props ( qw | BpropA
                           BpropB
                         |
                    , { name      => 'BnamedA'
                      }
                    , { name      => [ qw| Barr_namedA
                                           Barr_namedB
                                         |
                                     ]
                      }
                    , { name       => 'Bdefault'
                      , default    => 25
                      }
                    , { name       => 'BprotA'
                      , protected  => 1
                      }
                    , { name       => 'Bvalid'
                      , validation => sub { 1 }
                      }
                    , { name       => 'Binvalid'
                      , validation => sub { 0 }
                      }
                    , { name       => 'Bvalidat'
                      , validation => sub { /www/ }
                      }
                    , { name       => 'Bvalidat_default'
                      , validation => sub { /www/ }
                      , default    => 'wwwddd'
                      }
                    , { name       => 'Bmod_input'
                      , validation => sub { $_ = uc }
                      }
                    )
; sub writeBprotA
   { my ($s, $v) = @_
   ; $s->BprotA = $v
   }
                                 
; package SubClass
; use base 'BaseClass'





