package CGI::Builder::Test ;
$VERSION = 1.26 ;

# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use strict
; $Carp::Internal{+__PACKAGE__}++
             
; sub dump
   { my ($s, @args) = @_
   ; $s->page_content    .= sprintf qq(\nPage name: '%s'\n)
                                  , $s->page_name
   ; $s->page_content    .= "\nQuery Parameters:\n"
   ; foreach my $p ( sort $s->cgi->param() )
      { my $data_str      = "'"
                          . join "', '" , $s->cgi_>param($p)
                          . "'"
      ; $s->page_content .= "\t$p => $data_str\n"
      }
   ; $s->page_content    .= "\nQuery Environment:\n"
   ; foreach my $k ( sort keys %ENV )
      { $s->page_content .= "\t$k => '".$ENV{$k}."'\n"
      }
   ;
   }

; sub dump_html
   { my $s = shift
   ; my $c = ref $s
   ; $s->page_content     = "<HTML><HEAD><title>$c Dump</title></HEAD><BODY>"
   ; $s->page_content    .= sprintf qq(<P><B>Page name:</B> %s</P>\n)
                                  , $s->page_name
   ; $s->page_content    .= "<P><B>\nQuery Parameters:</B><BR>\n<OL>\n"
   ; foreach my $p ( sort $s->cgi->param() )
      { my $data_str      = "'"
                          . join "', '" , $s->cgi->param($p)
                          . "'"
      ; $s->page_content .= "<LI> $p => $data_str\n"
      }
   ; $s->page_content    .= "</OL>\n</P>\n";
   ; $s->page_content    .= "<P><B>\nQuery Environment:</B><BR>\n<OL>\n"
   ; foreach my $ek ( sort keys %ENV )
      { $s->page_content .= "<LI> <B>$ek</B> => ".$ENV{$ek}."\n"
      }
   ; $s->page_content    .= "</OL>\n</P>\n</BODY></HTML>\n";
   }
   
; sub die_handler
   { my $s = shift
   ; require Data::Dumper
   ; die sprintf qq(Fatal error in phase %s for page "%s": %s\n%s)
               , $CGI::Builder::Const::phase[$s->PHASE]
               , $s->page_name
               , $_[0]
               , Data::Dumper::Dumper($s)
   }
   
; 1

__END__

=head1 NAME

CGI::Builder::Test - Adds some testing methods to your build

=head1 VERSION 1.26

Included in CGI-Builder 1.26 distribution.

The latest versions changes are reported in the F<Changes> file in this distribution.

The distribution includes:

=over

=item CGI::Builder

Framework to build simple or complex web-apps

=item CGI::Builder::Const

Imports constants

=item CGI::Builder::Test

Adds some testing methods to your build

=item Bundle::CGI::Builder::Complete

A bundle to install the CBF and all its extensions and prerequisites

=back

To have the complete list of all the extensions of the CBF, see L<CGI::Builder/"Extensions List">

=head1 SYNOPSIS

  use CGI::Builder
  qw| CGI::Builder::Test
    |;

=head1 DESCRIPTION

This module adds just a couple of very basics methods used for debugging.

=head1 METHODS


=head2 dump()

    print STDERR $webapp->dump();

The dump() method returns a chunk of text which contains all the environment and CGI form data of the request, formatted for human readability.
Useful for outputting to STDERR.


=head2 dump_html()

    my $output = $webapp->dump_html();

The dump_html() method returns a chunk of text which contains all the environment and CGI form data of the request, formatted for human readability via a web browser. Useful for outputting to a browser.

=head1 SUPPORT

See L<CGI::Builder/"SUPPORT">.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.
