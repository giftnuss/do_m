# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use 5.006_001
; use ExtUtils::MakeMaker

; my $pm = 'lib/CGI/Builder.pm'

; WriteMakefile
   ( NAME           => 'CGI::Builder'
   , VERSION_FROM   => $pm
   , ( $] ge '5.005' )
     ? ( AUTHOR        => 'Domizio Demichelis - perl.4pro.net'
       , ABSTRACT_FROM => $pm
       )
     : ()
   , PREREQ_PM      => { 'Class::constr'  => '1.62'
                       , 'Class::props'   => '1.62'
                       , 'Class::groups'  => '1.62'
                       , 'Object::props'  => '1.62'
                       , 'Object::groups' => '1.62'
                       , 'IO::Util'       => '1.21'
                       }
   )

; 1
