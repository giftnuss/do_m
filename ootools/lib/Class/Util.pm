package Class::Util ;
$VERSION = 2.11 ;
use 5.006_001 ;
use strict ;
  
# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use Carp
; $Carp::Internal{+__PACKAGE__}++

; require Exporter
; our @ISA = 'Exporter'
; our @EXPORT_OK = qw| load
                       gather
                       blessed
                       classes
                     |

; sub import
   { my ($pkg, @subs) = @_
   ; require Class::ISA   if grep /^classes$/ , @subs
   ; $pkg->export_to_level(1, @_)
   }
   
; sub load
   { my $class = shift || $_
   ; my $r = eval "require $class;"
   ; if ($@)
      { (my $c = $class.'.pm') =~ s|\b::\b|/|g
      ; croak $@ if $@ !~ /^Can't locate $c in \@INC/
                    || not defined %{$class.'::'}
      }
   ; $r
   }

; sub gather (&$;$)
   { my( $code, $symbol, $packages ) = @_
   ; no strict 'refs'
   ; unless ( ref $packages eq 'ARRAY' )
      { my $class = defined($packages) &&! ref($packages)
                    ? $packages
                    : blessed($packages) || caller
      ; $packages =  classes($class)
      }
   ; my $t = substr $symbol, 0, 1, ''
   ; my $type = $t eq '*' ? 'GLOB'
              : $t eq '&' ? 'CODE'
              : $t eq '%' ? 'HASH'
              : $t eq '@' ? 'ARRAY'
              : $t eq '$' ? 'SCALAR'
              : croak 'Identifier must start with [*&%@$], died'
   ;  map { $code->() }
      map { *{$_.'::'.$symbol}{$type} }
     grep { defined( $type eq 'SCALAR'
                     ? ${$_.'::'.$symbol}
                     : *{$_.'::'.$symbol}{$type}
                   )
          }
          @$packages
   }

; sub blessed ($)
   { defined( $_[0] )
     && length( $_[0] )
     && eval{ $_[0]->isa( ref $_[0] ) }
     ? ref $_[0]
     : undef
   }
   
; sub classes
   { my $class = shift
   ; return () unless $class
   ; $class  = blessed($class) || $class || caller
   ; my @classes = ()
   ; my @stack   = ($class)
   ; my %skip    = ($class => 1)
   ; my $c
   ; while ( @stack )
      { next unless defined($c = shift @stack) && length $c
      ; unshift @classes, $c
      ; no strict 'refs';
      ; unshift @stack, map{ $skip{$_}++ ? () : $_ } @{$c.'::ISA'}
      }
   ; wantarray ? @classes : \@classes
   }

    
; 1

__END__

=pod

=head1 NAME

Class::Util - Class utility functions

=head1 VERSION 2.11

Included in OOTools 2.11 distribution.

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

=item * Class::Util

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

  use Class::Util;
  use Class::Util qw(load gather blessed);
  
  # will require 'Any::Module' from a variable
  
  $module = 'Any::Module';
  load $module;
  
  $_ = 'Any::Module'
  load;
  
  %defaults = gather { %$_ } '%default';
  
  $class = blessed $object or die 'Not a blessed object'
  

=head1 DESCRIPTION

This is a micro-weight module that (right now) exports only a few functions of general utility in Class operations.

=head1 FUNCTIONS

=head2 load [ $any_class ]

This function will require the I<any_class> and will croak on error. If no argument is passed it will use $_ as the argument. It is aware of the classes that have been loaded or declared in other loaded files, so it doesn't croak if the symbol table of the class is already defined, anyway you can check that by checking C<$@>.

It is useful if you need to load any module from a variable, since it avoids you to do:

   eval "require $class";
   if ( $@ ) { check_what_error and croak $@ };

=head2 gather {CODE} $symbol [, $classes ]

The C<gather> function executes the <CODE> block for each defined C<$symbol> found in C<$classes>, setting $_ as the reference to the found symbol and returns the list of results. C<$symbol> must be a string starting with C<*&%@$>; $classes may be a reference to an ARRAY of classes, a class name, or a blessed object. If $classes is omitted it uses the L<classes|"classes [$class|$object]"> of the caller; if it is a scalar it consider it as a class and uses the L<classes|classes [$class|$object]"> of that class.

This function is very useful if you want to implement data inheritance or if you want to implement overrunning, that is running the same method for each package that defines it (see for example L<CGI::Builder/"Overrunning">).

   # data inheritance example
   package RemoteBase;
   our %default = ( a=>1, b=>2 );
   
   package TheBase;
   our %default = (a=>10, c=>3);
   
   package main;
   use Class::Util qw(gather);
   our @ISA = qw(TheBase RemoteBase);
   our %default = ( d=>5 );
   
   my %defaults = gather { %$_ } '%default' ;
   
   print Dumper \%defaults ;

   # will print
   $VAR1 = { 'a' => 10,
             'b' => 2,
             'c' => 3,
             'd' => 5
           };

=head2 classes [$class|$object]

This function returns the list of all the classes that compose an object or a class (included the class itself). In scalar context it returns a reference to an ARRAY. If no arguments are passed it uses the caller package.

The returned classes are ordered from the more remote class to the class itself (included).

B<Note>: The result of this function is the reversed @ISA path that perl uses in order to find methods; the only exception is the C<UNIVERSAL> class, which is always omitted: if you need it unshift it to the result.

=head2 blessed $object

This function returns the blessed class of C<$object> ONLY if the object is blessed. It returns the undef value if C<$object> is not blessed.

=head1 SUPPORT

If you need support or if you want just to send me some feedback or request, please use this link: http://perl.4pro.net/?Class::Util.

=head1 AUTHOR and COPYRIGHT

� 2004-2005 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

=cut
