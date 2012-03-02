package Class::Util ;
$VERSION = 2.0 ;

# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use strict
; use Carp
; $Carp::Internal{+__PACKAGE__}++

; require Exporter
; our @ISA = 'Exporter'
; our @EXPORT_OK = qw| load
                     |
  
; sub load
   { my $class = shift || $_
   ; my $r = eval "require $class;"
   ; croak $@
     if $@ && $@ !~ /^Can't locate $class.pm in \@INC/
              || not defined %{"$class\::"}
   ; $r
   }

; 1

__END__

=head1 NAME

Class::Util - Class utility functions

=head1 VERSION 2.0

Included in OOTools 2.0 distribution.

The latest versions changes are reported in the F<Changes> file in this distribution.

The distribution includes:

=over

=item * Class::constr

Pragma to implement constructor methods

=item * Class::props

Pragma to implement lvalue accessors with options

=item * Class::groups

Pragma to implement groups of properties accessors with options

=item * Class::Error

Delayed checking of object failure

=item * Object::props

Pragma to implement lvalue accessors with options

=item * Object::groups

Pragma to implement groups of properties accessors with options

=item Class::Util

Class utility functions

=back

=head1 INSTALLATION

=over

=item Prerequisites

    Perl version >= 5.6.1

=item CPAN

    perl -MCPAN -e 'install OOTools'

=item Standard installation

From the directory where this file is located, type:

    perl Makefile.PL
    make
    make test
    make install

=back

=head1 SYNOPSIS

  use Class::Util qw(load);
  
  # will require 'Any::Module' from a variable
  
  $module = 'Any::Module';
  load $module;
  
  $_ = 'Any::Module'
  load;

=head1 DESCRIPTION

This is a micro-weight module that (right now) exports only a functions of general utility in Class operations.

=head1 FUNCTIONS

=head2 load [ any_class ]

This function will require the I<any_class> and will croak on error. If no argument is passed it will use $_ as the argument. It is aware of the classes that have been loaded or declared in other loaded files, so it doesn't croak if the symbol table of the class is already defined, anyway you can check that by checking C<$@>.

It is useful if you need to load any module from a variable, since it avoids you to do:

   eval "require $class";
   if ( $@ ) { check_what_error and croak $@ };

=head1 SUPPORT

If you need support or if you want just to send me some feedback or request, please use this link: http://perl.4pro.net/?Class::Util.

=head1 AUTHOR and COPYRIGHT

© 2004-2005 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.
