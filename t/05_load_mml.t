#!perl -w
; use strict
; use warnings
; use Test::More tests => 38

; use IO::Util qw(load_mml)
#; use Data::Dumper

; my $str1 = << 'EOS'
<opt>
  ignored text
  <a>01</a>
  ignored text
  <a>02</a>
  <b>   ignored text
    <c>05</c>
  </b>
  <a attribute="ignored">03</a>  <ignored_element/>
  <a>04</a>
  <d></d>
  <e>06 <ignored_element></e>
</opt>
EOS

# defaults
; my $r1 = load_mml( \$str1
                   , { strict => 0
                     }
                   )

#; warn Dumper $r1

; is( ref $$r1{a}, 'ARRAY')
; is( $$r1{a}[0] , '01'   )
; is( $$r1{a}[3] , '04'   )
; is( $$r1{b}{c} , '05'   )
; is( $$r1{d}    , ''     )
; is( $$r1{e}    , '06 <ignored_element>' )


# keep_root option
; my $r2 =  load_mml( \$str1
                    , { keep_root => 1
                      , strict    => 0
                      }
                    )
#; warn Dumper $r2

; is( ref $$r2{opt}{a}, 'ARRAY')
; is( $$r2{opt}{a}[0] , '01'   )
; is( $$r2{opt}{a}[3] , '04'   )
; is( $$r2{opt}{b}{c} , '05'   )
; is( $$r2{opt}{d}    , ''     )



# strict option
; my $str2 = << 'EOS'
<opt>
  <a>01</a>
  <a>02</a>
  <b>
    <c>05</c>
  </b>
</opt>
EOS

; my $r3 = load_mml( \$str2
                   , { strict => 1
                     }
                   )

#; warn Dumper $r3

; is( ref $$r3{a}, 'ARRAY')
; is( $$r3{a}[0] , '01'   )



; eval
   { load_mml( \'<opt>garbage<a>01</a></opt>'
             , { strict => 1
               }
             )
   }
; ok( $@ )
; eval
   { load_mml( \'<opt><a attr="garbage">01</a></opt>'
             , { strict => 1
               }
             )
   }
; ok( $@ )
; eval
   { load_mml( \'<opt><a>01<element attr="b"\></a></opt>'
             , { strict => 1
               }
             )
   }
; ok( $@ ) #'

# data_filter option
; my $str3 = << 'EOS'
<opt>
<a>
  abc
</a>
<b>
  def
  ghi
</b>
<c>
  <d>d</d>
  <e>e</e>
</c>
<f>f</f>
</opt>
EOS
; my $r4 =  load_mml( \$str3 )
#; warn Dumper $r4

; is( $$r4{a}, "\n  abc\n")

; my $r5 =  load_mml( \$str3
                    , { filter => { qr/./ => 'ONE_LINE'
                                  }
                      }
                    )
#; warn Dumper $r5

; is( $$r5{a}, '   abc ')


; my $r6 = load_mml( \$str3
                   , { filter => { qr/./ => \&IO::Util::TRIM_BLANKS
                                 }
                     }
                   )
#; warn Dumper $r6
; is( $$r6{b}, "def\nghi")

; my $r7 = load_mml( \$str3
                   , { filter => { qr/./ => \&trim_and_one_line
                                 }
                     }
                   )
#; warn Dumper $r7
; sub trim_and_one_line
   { IO::Util::TRIM_BLANKS()
   ; IO::Util::ONE_LINE()
   }
   
; is( $$r7{b}, "def ghi")

; my $r8 = load_mml( \$str3
                   , { filter => { qr/./ => sub{ trim_and_one_line()
                                               ; uc
                                               }
                                 }
                     }
                   )
#; warn Dumper $r8
; is( $$r8{b}, "DEF GHI")


# element_handler option
# change options

; my $r9 = load_mml( \$str3
                   , { filter => { qr/d|e/ => sub{ uc }
                                 }
                     }
                   )
#; warn Dumper $r9
; is( $$r9{c}{d}, "D")
; is( $$r9{c}{e}, "E")
; is( $$r9{f}, "f")

; my $r10 = load_mml( \$str3
                    , { handler => { c => \&c_struct_change }
                      }
                    )

# structure change
; sub c_struct_change
   { my $str = IO::Util::parse_mml(@_)
   ; [ sort values %$str ]
   }
#; warn Dumper $r10


; is( ref $$r10{c}, 'ARRAY' )
; is( $$r10{c}[0], 'd' )
; is( $$r10{c}[1], 'e' )
  
# skip element
; my $r11 = load_mml ( \$str3
                     , { handler => {c=>sub{}}
                       }
                     )
#; warn Dumper $r11

; ok(! defined $$r11{c} )
   
# object creation
; my $r12 = load_mml ( \$str3
                     , { handler => {c=>\&c_obj}
                       }
                     )

; sub c_obj
   { my $str = IO::Util::parse_mml(@_)
   ; bless $str, 'My::Class'
   }
   
#; warn Dumper $r12
; ok( $$r12{c}->isa('My::Class')  )

# matrix with folding
; my $str4 = << 'EOS'
<opt>

  <a>
    <b>01</b>
    <b>02</b>
  </a>
  <a>
    <b>03</b>
    <b>04</b>
  </a>
  
</opt>
EOS

; my $r13 = load_mml( \$str4
                    , { handler => { a => \&a_struct_change
                                   }
                      }
                    )
                    
; sub a_struct_change
   { my $str = IO::Util::parse_mml(@_)
   # folding 'b'
   ; $$str{b}
   }

#; warn Dumper $r13

; is( ref $$r13{a}, 'ARRAY')
; is( ref $$r13{a}[0], 'ARRAY')
; is( $$r13{a}[0][0], '01')
; is( $$r13{a}[1][0], '03')


# escape/unescape
; my $str5 = << 'EOS'
<opt>

  <a>\<b\>01\</b\></a>
  <b>\<b\>01\</b\></b>
  <c>\<b\>\\\</b\></c>
  
</opt>
EOS

; my $r14 = load_mml( \$str5 )

#; warn Dumper $r14

; is( $$r14{a}, '<b>01</b>')
; is( $$r14{b}, '<b>01</b>')
; is( $$r14{c}, '<b>\</b>')

# comments

; my $str6 = << 'EOS'
<opt>
   <a>01</a>
<!--   <b>
02</b>  -->

</opt>
EOS

; my $r15 = load_mml( \$str6 )

#; warn Dumper $r15
; is( $$r15{a}, '01')
; is( $$r15{b}, undef)




