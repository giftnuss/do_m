package IO::Util ;
$VERSION = 1.2 ;

; use strict
; use Carp
; $Carp::Internal{'IO::Util'}++
; require Exporter
; our @ISA = 'Exporter'
; our @EXPORT_OK = qw| capture
                       slurp
                     |
; my $output

; sub capture (&;*)
   { my $code = shift
   ; $output = ''
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
   ; \$output
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
   ; if (  ref     eq 'GLOB'
        || ref \$_ eq 'GLOB'
        )
      { $_ = do { local $/; <$_> }
      }
     elsif ( defined && length && not ref )
      { open _ or croak "$^E"
      ; $_ = do { local $/; <_> }
      ; close _
      }

     else                     # it's something else
      { croak 'Wrong argument type: "'. ( ref || 'UNDEF' ) . '"'
      }
   ; \$_
   }
      
; 1

__END__

=head1 NAME

IO::Util - A selection of general-utility IO function

=head1 VERSION 1.2

The latest versions changes are reported in the F<Changes> file in this distribution.

=head1 SYNOPSIS

    use IO::Util qw(capture slurp);
    
    # captures the selected file handler
    $output_ref = capture { some_printing_code() } ;
    
    sub some_printing_code {
        print 'something'
    }
    
    # captures FILEHANDLER
    $output_ref = capture { some_special_printing_code() } FILEHEANDLER ;
    
    sub some_special_printing_code {
        print FILEHANDLER 'something'
    }
    
    $content_ref = slurp '/path/to/file' ;
    $content_ref = slurp \*FILEHANDLER ;
    

=head1 DESCRIPTION

This is a micro-weight module that exports just a couple of functions of general utility in IO operations.

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

=head1 FUNCTIONS

=head2 capture { code } [ FILEHANDLER ]

The C<capture> function espects a I<code> block as the first argument and an optional I<FILEHANDLER> as the second argument. If I<FILEHANDLER> is omitted the selected file handler will be used by default (usually C<STDOUT>). The function returns the reference to the captured output.

It executes the code inside the first argument block, and captures the output it sends to the selected file handler (or to a specific file handler). It "hijacks" all the C<print> and C<printf> statements addressed to the captured filehandler, returning the scalar reference to the output. Sort of "print to scalar" function.

B<Note>: This function ties the I<FILEHANDLER> to IO::Util class and unties it after the execution of the I<code>. If I<FILEHANDLER> is already tied to any other class, it just temporary re-bless the tied object to IO::Util class, re-blessing it again to its original class after the execution of the I<code>, thus preserving the original I<FILEHANDLER> configuration.

=head2 slurp [ file|FILEHANDLER ]

The C<slurp> function expects a path to a I<file> or an open I<FILEHANDLER>, and  returns the reference to the whole I<file|FILEHANDLER> content. If no argument is passed it will use $_ as the argument.

=head1 SUPPORT and FEEDBACK

If you need support or if you want just to send me some feedback or request, please use this link: http://perl.4pro.net/?IO::Util.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

