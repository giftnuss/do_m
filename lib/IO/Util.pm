package IO::Util ;
$VERSION = 1.01 ;

; use strict

; require Exporter
; our @ISA = 'Exporter'
; our @EXPORT_OK = qw(capture)

; sub capture (&;*)
   { my $code = shift()
   ; local(*H) = shift() || select()
   ; my $output = ''
   ; tie *H
       , __PACKAGE__
       , \$output
   ; &{$code}()
   ; untie *H
   ; \$output
   }

; sub TIEHANDLE
   { bless \@_, shift()
   }

; sub PRINT
   { my $s = shift
   ; ${$$s[0]} .= join( ($,||''), map{ defined($_) ? $_ : '' } @_ )
   }

; 1

__END__

=head1 NAME

IO::Util - Captures the output sent to a file handler

=head1 VERSION 1.01


=head1 SYNOPSIS

    use IO::Util qw(capture);
    
    # captures the selected file handler
    $output_ref = capture { some_printing_code } ;
    
    # captures FILEHANDLER
    $output_ref = capture { some_printing_code } FILEHEANDLER ;
    
    sub some_printing_code {
        print 'something'
    }

=head1 DESCRIPTION

This is a micro-weight module that exports just the C<capture> function. It executes the code inside the first argument block, and captures the output it sends to the selected file handler (or to a specific file handler). It "hijacks" all the C<write> and C<print> statements addressed to the captured filehandler, returning the scalar reference of the output. Sort of "print to scalar" function.

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

=head1 SUPPORT and FEEDBACK

If you need support or if you want just to send me some feedback or request, please use this link: http://perl.4pro.net/?IO::Util.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

