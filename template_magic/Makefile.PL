# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use 5.006_001
; use ExtUtils::MakeMaker

; my $dist = 'Template::Magic'
; my $vers = '1.24'

; WriteMakefile
   ( NAME           => $dist
   , VERSION        => $vers
   , ( $] ge '5.005' )
     ? ( AUTHOR     => 'Domizio Demichelis - perl.4pro.net'
       , ABSTRACT   => 'Magic merger of runtime values with templates'
       )
     : ()
   , PREREQ_PM      => { 'Class::constr'  => '1.52'
                       , 'Class::props'   => '1.52'
                       , 'Object::props'  => '1.52'
                       , 'IO::Util'       => '1.21'
                       , 'File::Spec'     => '0'
                       }
   )


; 1
