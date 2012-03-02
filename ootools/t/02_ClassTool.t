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

   # 02 ############
   ; my $o2 = $class->new( BpropA => 25
                         , BpropB => 3
                         )
   ; is( $o2->BpropA * $o2->BpropB
       , 75
       , 'Passing new properties with new' )

       
   ; is( $o1->BpropA * $o1->BpropB
       , 75
       , 'Other object same test' )
        
   # 03 ############
   ; eval
      { my $o3 = $class->new( unknown => 10 )
      }
   ; ok( $@
       , 'Passing an unknow property'
       )
    
   # 04 ############
   ; is( $class->Bdefault
       , 25
       , "Reading default"
       )

   # 05 ############
   ; $class->Bvalid = 5
   ; is( $class->Bvalid
       , 5
       , 'Writing an always valid property'
       )

   # 06 ############
   ; $class->writeBprotA(5)
   ; is( $class->BprotA
       , 5
       , "Writing protected property from class"    #####
       )
       
   # 07 ############
   ; eval
      { $class->BprotA = 10
      }
   ; ok( $@
       , 'Trying to write a protected property from outside'
       )

   # 08############
   ; $class->writeBprotA(8)
   ; is( $class->BprotA
       , 8
       , "Writing again protected property from class"
       )

   # 09 ############
   ; is( $class->Bvalidat('aawwwbb')
       , 'aawwwbb'
       , 'Writing a valid value'
       )

   # 10 ############
   ; eval
      { $class->Bvalidat = 10
      }
   ; ok( $@
       , 'Writing an invalid value'
       )
       
   # 11 ############
   ; is( $class->Bvalidat('aawwwbb')
       , 'aawwwbb'
       , 'Writing again a valid value'
       )
       
   # 12 ############
   ; is( $class->Bvalidat_default('aawwwbb')
       , 'aawwwbb'
       , 'Writing a valid value in a property with default'
       )

## 13 ############
   ; ok( (not $class->Barr_namedA)
       , 'Default undef value'
       )

   ## 14 ############
   ; $class->Bdefault = 56
   ; undef $class->Bdefault
   ; is( $class->Bdefault
       , 25
       , 'Reset to default'
       )

   ## 15 ############
   ; $class->Bmod_input = 'abc'
   ; is( $class->Bmod_input
       , 'ABC'
       , 'Modifying input'
       )

   }


; package BaseClass

; use Class::new


; use Class::props ( qw | BpropA
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





