package Class::constr ;
$VERSION = 1.31 ;

; use 5.006_001
; use strict
; use Carp

; use constant START_SUB => q!
  sub
   { my $c = shift
   ; croak qq(Can't call method "$n" on a reference)
           if ref $c
   ; croak qq(Odd number of arguments for "$c->$n")
           if @_ % 2
   ; my $s = bless {}, $c
   ; while ( my ($p, $v) = splice @_, 0, 2 )
      { if ( $constr{no_strict} )
         { $$s{$p} = $v
         }
        else
         { $s->can($p)
           or croak qq(No such property "$p")
         ; { local $Carp::Internal{+__PACKAGE__} = 1
           ; $s->$p( $v )
           }
         }
      }
!
; use constant INIT_LOOP => q!
   ; foreach my $m ( @{$constr{init}} )
      { $s->$m(@_)
      }
!
; use constant END_SUB => q!
   ; $s
   }
!

; sub import
   { my ($pkg, %constr) = @_
   ; my $callpkg = caller
   ; my $n = $constr{name} || 'new'
 
   ; $constr{init} &&= [ $constr{init} ]
                     unless ref $constr{init} eq 'ARRAY'
   ; my $sub = START_SUB
   ;    $sub .= INIT_LOOP if $constr{init}
   ;    $sub .= END_SUB

   ; no strict 'refs'
   ; eval '*{"$callpkg\::$n"} ='. $sub
   ; croak $@ if $@
   ; print "### $callpkg\::$n ###$sub\n" if our $print_codes
   }


; 1

__END__

=head1 NAME

Class::constr - Pragma to implement constructor methods

=head1 VERSION 1.31

Included in OOTools 1.31 distribution. The distribution includes:

=over

=item * Class::constr

Pragma to implement constructor methods

=item * Class::props

Pragma to implement lvalue accessors with options

=item * Class::group

Pragma to implement group of properties accessors with options

=item * Object::props

Pragma to implement lvalue accessors with options

=item * Object::group

Pragma to implement group of properties accessors with options

=back

=head1 SYNOPSIS

=head2 Class

    package MyClass ;
    
    # implement constructor without options
    use Class::constr ;
    
    # with options
    use Class::constr  name      => 'new_object' ,
                       init      => [ qw( init1 init2 ) ] ,
                       no_strict => 1  ;
                    
    # init1 and init2 will be called at run-time
    
=head2 Usage

    # creates a new object and eventually validates
    # the properties if any validation property option is set
    my $object = MyClass->new(digits => '123');
                                 
=head1 DESCRIPTION

This pragma easily implements lvalue constructor methods for your class. Use it with C<Class::props> and C<Object::props> to automatically validate the input passed with C<new()>, or use the C<no_strict> option to accept unknow properties as well.

You can completely avoid to write the constructor by just using it and eventually declaring the name and the init methods to call.

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

=head2 OPTIONS

=over

=item name

The name of the constructor method. If you omit this option the 'new' name will be used by default.

=item no_strict

With C<no_strict> option set to a true value, the constructor method accepts and sets also unknown properties (i.e. not predeclared). You have to access the unknown properties without any accessor method. All the other options will work as expected. Without this option the constructor will croak if any property does not have an accessor method.

=item init

Use this option if you want to call other method in your class to further initialize the object. You can group methods by passing a reference to an array containing the method names.

After the assignation and validation of the properties, the initialization methods in the C<init> option will be called. Each init method will receive the blessed object passed in C<$_[0]> and the other (original) parameter in the remaining C<@_>.

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Class::constr.

=head1 AUTHOR and COPYRIGHT

© 2003 by Domizio Demichelis <dd@4pro.net>.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

=head1 CREDITS

Thanks to Juerd Waalboer (http://search.cpan.org/author/JUERD) that with its I<Attribute::Property> inspired the creation of this distribution.

