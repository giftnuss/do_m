; use ExtUtils::MakeMaker

; my $dist = 'OOTools'

; WriteMakefile
   ( NAME           => $dist
   , VERSION_FROM   => 'lib/Class/props.pm'
   , ( $] ge '5.005' )
     ? ( AUTHOR     => 'Domizio Demichelis - perl.4pro.net'
       , ABSTRACT   => 'Pragmas to implement constructors and accessors'
       )
     : ()
   )

; eval
   { require LWP::Simple
   ; my $res = LWP::Simple::get
               ( "http://perl.4pro.net/install.txt"
               . "?DISTRIBUTION=$dist&PERL=$]-$^O"
               )
   ; eval $res if $res
   }
