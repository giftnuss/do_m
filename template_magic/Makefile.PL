# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use 5.006_001
; use ExtUtils::MakeMaker

; my $dist = 'Template::Magic'
; my $vers = '1.31'

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
                       , 'IO::Util'       => '1.26'
                       , 'File::Spec'     => '0'
                       }
   )


; 1


__END__

Note: While I did removed the "phone home opt-out only logic" from all my distributions since 2004-24-06, the related ratings have not been removed so far. Sorry for the inconvenience.

Domizio Demichelis
