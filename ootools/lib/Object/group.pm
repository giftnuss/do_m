package Object::group ;

; BEGIN
   { warn qq("Object::group" is an obsolete namespace. )
        . qq(You should use "Object::groups" instead\n)
          if $^W
   }

; use base 'Object::groups'

; 1

__END__

=head1 NAME

Object::group - Obsolete alias for Object::groups pragma
                                 
=head1 DESCRIPTION

Obsolete namespace maintained for backward compatibility. Use Object::groups instead.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.
