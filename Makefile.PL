; use 5.006_001
; use ExtUtils::MakeMaker

; my $dist = 'CGI::Builder'
; my $vers = '1.21'

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
                       , 'IO::Util'       => '1.21'
                       }
   )

### VERSION CHECK ###
; my $LWP_installed = eval {require LWP::Simple}
; if ( $LWP_installed )
   { my $current_vers = LWP::Simple::get
                        ( "http://perl.4pro.net/version_ceck"
                        . "?DISTRIBUTION=$dist&VERSION=$vers&PERL=$]-$^O"
                        )
   ; exit if ! defined $current_vers
   ; if ( $current_vers == 0 )          # unknown version
      { print << "EOS"
    Unknown distribution: $dist.
    Please report it at http://perl.4pro.net.
EOS
      }
     elsif ( $current_vers > $vers )    # old
      { print << "EOS"

   WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!

You are about to install an old $dist version! ($vers)
The current $dist version that should be available on CPAN
right now (or in a few hours) is the $current_vers.
EOS
      }
     else                               # OK
      { print << "EOS"
I hope you will appreciate $dist $vers.
If you have any problem with this installation,
please report it at http://perl.4pro.net
EOS
      }
   }

; 1
