# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; package CGI::Builder::Const

; use strict

; my $h
; our (@phase, $END)

; BEGIN
   { @phase  = qw | CB_INIT
                    GET_PAGE
                    PRE_PROCESS
                    SWITCH_HANDLER
                    PRE_PAGE
                    PAGE_HANDLER
                    FIXUP
                    RESPONSE
                    REDIR
                    CLEANUP
                  |
   ; @$h{@phase} = (0 .. $#phase)
   ; while ( my ($k, $v) = each %$h )
      { no strict 'refs'
      ; *$k = sub () { $v }
      }
   }

; require Exporter
; our @ISA = 'Exporter'
; our @EXPORT_OK   = ( @phase )
; our %EXPORT_TAGS = ( all      => \@phase
                     , phases   => \@phase
                     )
                     
; 1

__END__

=head1 NAME

CGI::Builder::Const - Imports constants

=head1 SYNOPSIS

  use CGI::Builder::Const qw| :all | ;

=head1 DESCRIPTION

This module is internally used by the CBF. You don't need to use it unless you are writing some very heavy extension :-).

=head1 CONSTANTS

=head2 :phases

These constant are used to set and check the Process Phase. They return just a progressive integer:

  CB_INIT         0
  GET_PAGE        1
  PRE_PROCESS     2
  SWITCH_HANDLER  3
  PRE_PAGE        4
  PAGE_HANDLER    5
  FIXUP           6
  RESPONSE        7
  REDIR           8
  CLEANUP         9

=head1 SUPPORT

See L<CGI::Builder/"SUPPORT">.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.
