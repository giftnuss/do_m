package IO::Util ;
$VERSION = 1.3 ;

# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use strict
; use Carp
; $Carp::Internal{'IO::Util'}++
; require Exporter
; our @ISA = 'Exporter'
; our @EXPORT_OK = qw| capture
                       slurp
                       Tid Lid Uid
                     |
; our $output
; my %charset = ( base34 => [ 1..9, 'A'..'N', 'P'..'Z' ]
                , base62 => [ 0..9, 'a'..'z', 'A'..'Z' ]
                )
; my $separator = '_'

; sub import
   { my ($pkg, @subs) = @_
   ; require Time::HiRes   if grep /id$/  , @subs
   ; require Sys::Hostname if grep /^Uid$/, @subs
   ; $pkg->export_to_level(1, @_)
   }
 
; sub _convert
   { my ( $num, $args ) = @_
   ; my $chars = defined $$args{chars}
                 ? ref($$args{chars}) eq 'ARRAY'
                   ? $$args{chars}
                   : exists $charset{$$args{chars}}
                     ? $charset{$$args{chars}}
                     : croak 'Invalid chars'
                 : $charset{base34}
   ; my $result = ''
   ; my $dnum = @$chars
   ; while ( $num > 0 )
      { substr($result, 0, 0)
        = $$chars[ $num % $dnum]
      ; $num = int($num/$dnum)
      }
   ; $result
   }

; sub Tid
   { my %args = @_
   ; my $sep = $args{separator} || $separator
   ; my($sec, $usec) = Time::HiRes::gettimeofday()
   ; my($new_sec, $new_usec)
   ; do{ ($new_sec, $new_usec) = Time::HiRes::gettimeofday() }
       until ( $new_usec != $usec || $new_sec != $sec )
   ; join $sep, map _convert($_, \%args), $sec , $usec
   }
   
; sub Lid
   { my %args = @_
   ; my $sep = $args{separator} || $separator
   ; join $sep, _convert($$, \%args), Tid(@_)
   }

; sub Uid
   { my %args = @_
   ; my $sep = $args{separator} || $separator
   ; my $ip = sprintf '1%03d%03d%03d%03d'
            , $args{IP}
              ? @{$args{IP}}
              : unpack( "C4", (gethostbyname(Sys::Hostname::hostname()))[4] )
   ; join $sep, _convert($ip, \%args), Lid(@_)
   }
   
; sub capture (&;*)
   { my $code = shift
   ; local $output
   ; my $fh = shift || select
   ; no strict 'refs'
   ; if ( my $to = tied *$fh )
      { my $tc = ref $to
      ; bless $to, __PACKAGE__
      ; &{$code}()
      ; bless $to, $tc
      }
     else
      { tie *$fh , __PACKAGE__
      ; &{$code}()
      ; untie *$fh
      }
   ; my $out = $output    # copy to lexical fixes -T bug
   ; \ $out
   }
                  
; sub TIEHANDLE
   { bless \@_, shift
   }

; sub PRINT
   { shift
   ; $output .= join $,||'', map{ defined($_) ? $_ : '' } @_
   ; $output .= $\||''
   }

; sub PRINTF
   { shift
   ; my $fmt = shift
   ; $output .= sprintf $fmt, @_
   }
           
; sub slurp
   { local ($_) = @_ ? $_[0] : $_
   ; my $content
   ; if (  ref     eq 'GLOB'
        || ref \$_ eq 'GLOB'
        )
      { $content = do { local $/; <$_> }
      }
     elsif ( defined && length && not ref )
      { open _ or croak "$^E"
      ; $content = do { local $/; <_> }
      ; close _
      }
     else                     # it's something else
      { croak 'Wrong argument type: "'. ( ref || 'UNDEF' ) . '"'
      }
   ; \ $content
   }


; 1

__END__

=head1 NAME

IO::Util - A selection of general-utility IO function

=head1 VERSION 1.3

The latest versions changes are reported in the F<Changes> file in this distribution.

=head1 INSTALLATION

=over

=item CPAN

    perl -MCPAN -e 'install IO::Util'

=item Standard installation

From the directory where this file is located, type:

    perl Makefile.PL
    make
    make test
    make install

=back

=head1 SYNOPSIS

  use IO::Util qw(capture slurp uniqid);
  
  # captures the selected file handler
  $output_ref = capture { any_printing_code() } ;
  # now $$output_ref eq 'something'
  
  sub any_printing_code {
      print 'something'
  }
  
  
  # captures FILEHANDLER
  $output_ref = capture { any_special_printing_code() } FILEHEANDLER ;
  # now $$output_ref eq 'something'
  
  sub any_special_printing_code {
      print 'to STDOUT';
      print FILEHANDLER 'something'
  }
  
  
  $_ = '/path/to/file' ;
  $content_ref = slurp ;
  
  $content_ref = slurp '/path/to/file' ;
  $content_ref = slurp \*FILEHANDLER ;
  
  $temporarily_unique_id = Tid()  # like 'Q9MU1N_NVRM'
  $locally_unique_id     = Lid()  # like '2MS_Q9MU1N_P5F6'
  $universally_unique_id = Uid()  # like 'MGJFSBTK_2MS_Q9MU1N_PWES'

=head1 DESCRIPTION

This is a micro-weight module that exports a few functions of general utility in IO operations.

=head1 FUNCTIONS

=head2 capture { code } [ FILEHANDLER ]

The C<capture> function espects a I<code> block as the first argument and an optional I<FILEHANDLER> as the second argument. If I<FILEHANDLER> is omitted the selected file handler will be used by default (usually C<STDOUT>). The function returns the reference to the captured output.

It executes the code inside the first argument block, and captures the output it sends to the selected file handler (or to a specific file handler). It "hijacks" all the C<print> and C<printf> statements addressed to the captured filehandler, returning the scalar reference to the output. Sort of "print to scalar" function.

B<Note>: This function ties the I<FILEHANDLER> to IO::Util class and unties it after the execution of the I<code>. If I<FILEHANDLER> is already tied to any other class, it just temporary re-bless the tied object to IO::Util class, re-blessing it again to its original class after the execution of the I<code>, thus preserving the original I<FILEHANDLER> configuration.

=head2 slurp [ file|FILEHANDLER ]

The C<slurp> function expects a path to a I<file> or an open I<FILEHANDLER>, and  returns the reference to the whole I<file|FILEHANDLER> content. If no argument is passed it will use $_ as the argument.

=head2 *id ([ options ])

The C<*id> functions (C<Tid>, C<Lid> and C<Uid>) return an unique ID string useful to name temporary files, or use for other purposes.

=over

=item Tid

This function returns a temporary ID valid for the current process only. Different temporarily-unique strings are granted to be unique for the current process only ($$)

=item Lid

This function returns a local ID valid for the local host only. Different locally-unique strings are granted to be unique when generated by the same local host

=item Uid

This function returns an universal ID. Different universally-unique strings are granted to be unique also when generated by different hosts. use this function if you have more than one machine generating the IDs for the same context. This function includes the host IP number in the id algorithm.

=back

They accepts an optional hash of named arguments:

=over

=item chars

You can specify the set of characters used to generate the uniquid string. You have the following options:

=over

=item chars => 'base34'

uses [1..9, 'A'..'N', 'P'..'Z']. No lowercase chars, no number 0 no capital 'o'. Useful to avoid human mistakes when the uniqid may be represented by non-electronical means (e.g. communicated by voice or read from paper). This is the default (used if you don't specify any chars option).

=item  chars => 'base62'

Uses C<[0..9, 'a'..'z', 'A'..'Z']>. This option tryes to generate shorter ids.

=item chars => \@chars

Any reference to an array of arbitrary characters.


=back

=item separator

The character used to separate group of cheracters in the id. Default '_'.

=item IP

Applies to C<Uid> only. This option allows to pass the IP number used generating the universally-unique id. Use this option if you know what you are doing.

=back

   $ui = Tid()                         # Q9MU1N_NVRM
   $ui = Lid()                         # 2MS_Q9MU1N_P5F6
   $ui = Uid()                         # MGJFSBTK_2MS_Q9MU1N_PWES
   $ui = Uid(separator=>'-')           # MGJFSBTK-2DH-Q9MU6H-7Z1Y
   $ui = Tid(chars=>'base62')          # 1czScD_2h0v
   $ui = Lid(chars=>'base62')          # rq_1czScD_2jC1
   $ui = Uid(chars=>'base62')          # jQaB98R_rq_1czScD_2rqA
   $ui = Lid(chars=>[ 0..9, 'A'..'F']) # 9F4_41AF2B34_62E76

B<IMPORT NOTE>: If you really want to use C<IO::Util::*id> from its package without importing any symbol (and only in that case), you must explicitly load C<Time::HiRes>. You must also load C<Sys::Hostname> if you use C<IO::Util::Uid>:

   use IO::Util ()   ; # no symbol imported
   use Time::HiRes   ; # used by any IO::Util::*id
   use Sys::Hostname ; # used by IO::Util::Uid
   
   $uniqid = IO::Util::Uid()

=head1 SUPPORT and FEEDBACK

If you need support or if you want just to send me some feedback or request, please use this link: http://perl.4pro.net/?IO::Util.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

