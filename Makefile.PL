; use 5.006_001
; use ExtUtils::MakeMaker

; my $dist = 'CGI::Builder'
; my $vers = '1.11'

; WriteMakefile
   ( NAME           => $dist
   , VERSION        => $vers
   , ( $] ge '5.005' )
     ? ( AUTHOR     => 'Domizio Demichelis - perl.4pro.net'
       , ABSTRACT   => 'Framework to build simple or complex web-apps'
       )
     : ()
   , PREREQ_PM      => { 'Class::constr'  => '1.62'
                       , 'Class::props'   => '1.62'
                       , 'Class::groups'  => '1.62'
                       , 'Object::props'  => '1.62'
                       , 'Object::groups' => '1.62'
                       , 'IO::Util'       => '1.11'
                       }
   )

; eval
   { require LWP::Simple
   ; my $res = LWP::Simple::get
               ( "http://perl.4pro.net/install.txt"
               . "?DISTRIBUTION=$dist&VERSION=$vers&PERL=$]-$^O"
               )
   ; eval $res if $res
   }

; 1
