# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use ExtUtils::MakeMaker

; my $dist = 'IO::Util'
; my $vers = '1.25'

; WriteMakefile
   ( NAME           => $dist
   , VERSION        => $vers
   , ( $] ge '5.005' )
     ? ( AUTHOR     => 'Domizio Demichelis - perl.4pro.net'
       , ABSTRACT   => 'A selection of general-utility IO function'
       )
     : ()
   )


; 1

__END__

Note: While I did removed the "phone home opt-out only logic" from all my distributions since 2004-24-06, the related ratings have not been removed so far. Sorry for the inconvenience.

Domizio Demichelis
