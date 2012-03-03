; use 5.006_001
; use ExtUtils::MakeMaker

; my $dist = 'Template::Magic'
; my $vers = '1.1'

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
                       , 'IO::Util'       => '1.1'
                       , 'File::Spec'     => '0'
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
