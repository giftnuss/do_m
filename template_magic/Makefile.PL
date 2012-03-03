# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use 5.006_001
; use ExtUtils::MakeMaker

; my $pm = 'lib/Template/Magic.pm'

; WriteMakefile
   ( NAME           => 'Template::Magic'
   , VERSION_FROM   => $pm
   , ( $] ge '5.005' )
     ? ( AUTHOR     => 'Domizio Demichelis - perl.4pro.net'
       , ABSTRACT_FROM   => $pm
       )
     : ()
   , PREREQ_PM      => { 'Class::constr'  => 1.52
                       , 'Class::props'   => 1.52
                       , 'Object::props'  => 1.52
                       , 'IO::Util'       => 1.43
                       , 'File::Spec'     => 0
                       }
   )


; 1

