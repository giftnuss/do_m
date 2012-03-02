package Class::group ;

; BEGIN
   { warn qq("Class::group" is an obsolete namespace. )
        . qq(You should use "Class::groups" instead\n)
          if $^W
   }
   
; use base 'Class::groups'

; 1

__END__

=head1 NAME

Class::group - Obsolete alias for Class::groups pragma
                                 
=head1 DESCRIPTION

Obsolete namespace maintained for backward compatibility. Use Class::groups instead.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.
