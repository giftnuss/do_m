package IO::Util ;
$VERSION = 1.11 ;

; use strict

; require Exporter
; our @ISA = 'Exporter'
; our @EXPORT_OK = qw(capture)

; my $output

; sub capture (&;*)
   { my $code = shift()
   ; $output = ''
   ; local(*H) = shift() || select()
   ; if (my $to = tied *H)
      { my $tc = ref $to
      ; bless $to, __PACKAGE__
      ; &{$code}()
      ; bless $to, $tc
      }
     else
      { tie(*H , __PACKAGE__)
      ; &{$code}()
      ; untie *H
      }
   ; \$output
   }
                  
; sub TIEHANDLE
   { bless \@_, shift()
   }

; sub PRINT
   { shift
   ; $output .= join( ($,||''), map{ defined($_) ? $_ : '' } @_)
   ; $output .= $\||''
   }

; sub PRINTF
   { shift
   ; my $fmt = shift
   ; $output .= sprintf($fmt, @_)
   }
   
; 1

__END__

=head1 NAME

IO::Util - Captures the output sent to a file handler

=head1 VERSION 1.11

The latest versions changes are reported in the F<Changes> file in this distribution.

=head1 SYNOPSIS

    use IO::Util qw(capture);
    
    # captures the selected file handler
    $output_ref = capture { some_printing_code } ;
    
    sub some_printing_code {
        print 'something'
    }
    
    # captures FILEHANDLER
    $output_ref = capture { some_special_printing_code } FILEHEANDLER ;
    
    sub some_special_printing_code {
        print FILEHANDLER 'something'
    }

=head1 DESCRIPTION

This is a micro-weight module that exports just the C<capture> function. It executes the code inside the first argument block, and captures the output it sends to the selected file handler (or to a specific file handler). It "hijacks" all the C<print> and C<printf> statements addressed to the captured filehandler, returning the scalar reference of the output. Sort of "print to scalar" function.

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

B<Note>: This function ties the I<FILEHANDLER> to IO::Util class and unties it after the execution of the I<code>. If I<FILEHANDLER> is already tied to any other class, it just re-bless the tied object to IO::Util class and re-bless again the tied object to its original class after the execution of the I<code>, thus preserving the original I<FILEHANDLER> configuration.

=head1 SUPPORT and FEEDBACK

If you need support or if you want just to send me some feedback or request, please use this link: http://perl.4pro.net/?IO::Util.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

