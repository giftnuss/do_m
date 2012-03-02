package Class::new ;

; warn qq("Class::new" is an obsolete namespace. )
     . qq(You should use "Class::constr" instead)
       if $^W

; use base 'Class::constr'

; 1

__END__

=head1 NAME

Class::new - Obsolete alias for Class::constr pragma
                                 
=head1 DESCRIPTION

Obsolete namespace maintained for backward compatibility. Use Class::constr instead.

=head1 AUTHOR and COPYRIGHT

© 2003 by Domizio Demichelis <dd@4pro.net>.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.
