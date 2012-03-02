package Object::props ;
$VERSION = 1.11 ;

use base 'Base::OOTools' ;

1 ;

__END__

=head1 NAME

Object::props - Pragma to implement lvalue accessors with options

=head1 VERSION 1.11

Included in OOTools 1.11 distribution. The distribution includes:

=over

=item * Class::new

Pragma to implement constructor methods

=item * Class::props

Pragma to implement lvalue accessors with options

=item * Object::props

Pragma to implement lvalue accessors with options

=back

=head1 SYNOPSIS

=head2 Class

    package MyClass ;
    
    # implement constructor without options
    use Class::new ;
    
    # just accessors without options (list of strings)
    use Object::props @prop_names ;
    
    # a property with validation and default (list of hash refs)
    use Object::props { name       => 'digits',
                        validation => sub{ /^\d+\z/ }       # just digits
                        default    => 10
                      } ;
    
    # a group of properties with common full options
    use Object::props { name       => \@other_prop_names,   # array ref
                        default    => 'something' ,
                        validation => sub{ /\w+/ }
                        protected  => 1
                      } ;
                      
    # all the above in just one step (list of strings and hash refs)
    use Object::props @prop_names ,
                      { name       => 'digits',
                        validation => sub{ /^\d+\z/ }
                        default    => 10
                      } ,
                      { name       => \@other_prop_names,
                        default    => 'something' ,
                        validation => sub{ /\w+/ }
                        protected  => 1
                      } ;
    

=head2 Usage

    my $object = MyClass->new(digits => '123');
    
    $object->digits    = '123';
    
    $object->digits('123');
    
    my $d = $object->digits;  # $d == 123
    
    undef $object->digits     # $object->digits == 10 (default)
    
    # This would croak
    $object->digits    = "xyz";


=head1 DESCRIPTION

This pragma easily implements lvalue accessor methods for the properties of your object (I<lvalue> means that you can create a reference to it, assign to it and apply a regex to it).

You can completely avoid to write the accessor by just declaring the names and eventually the default value, validation code and other option of your properties.

=head2 Class properties vs Object properties

The main difference between C<Object::props> and C<Class::props> is that the first pragma creates instance properties related with the object and stored in $object->{property}, while the second pragma creates class properties related with the class and stored in $Class::property.

A Class property is accessible either through the class or through all the objects of that class, while an object property is accessible only through the object that set it.

   package MyClass;
   use Class::new ;
   use Object::props 'obj_prop' ;
   use Class::props qw( class_prop1
                        class_prop2 ) ;
   
   package main ;
   my $object1 = MyClass->new( obj_prop    => 1   ,
                               class_prop1 => 11 ) ;
   my $object2 = MyClass->new( obj_prop    => 2    ,
                               class_prop2 => 22 ) ;
   
   print $object1->obj_prop    ; # would print 1
   print $object1->{obj_prop}  ; # would print 1
   
   print $object2->obj_prop    ; # would print 2
   print $object2->{obj_prop}  ; # would print 2
   
   print $object1->class_prop1 ; # would print 11
   print $object2->class_prop1 ; # would print 11
   print $MyClass::class_prop1 ; # would print 11
   
   print $object1->class_prop2 ; # would print 22
   print $object2->class_prop2 ; # would print 22
   print $MyClass::class_prop2 ; # would print 22
   
   $object2->class_prop1 = 100 ; # object method
   MyClass->class_prop2  = 200 ; # static method
   
   print $object1->class_prop1 ; # would print 100
   print $object2->class_prop1 ; # would print 100
   print $object1->class_prop2 ; # would print 200
   print $object2->class_prop2 ; # would print 200

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

The name of the property is used as the identifier to create the accessor method, and as the key of the blessed object hash.

Given 'my_prop' as the property name:

    $object->my_prop = 10 ;  # assign 10 to $object->{my_prop}
    $object->my_prop( 10 );  # assign 10 to $object->{my_prop}
    
    # same thing if MyClass::new is implemented
    # by the Class::new pragma
    
    $object = MyClass->new( my_prop => 10 );

You can group properties that have the same set of option by passing a reference to an array containing the names. If you don't use any option you can pass a list of plain names as well. See L<"SYNOPSYS">.

=item default

The property will be initially set to the I<default value>.  You can reset a property to its default value by assigning it the undef value.

    # this will reset the property to its default
    $object->my_prop = undef ;
    
    # this works as well
    undef $object->my_prop ;

If any C<validation> option is set, then the I<default value> is validated at compile time. If no C<default> option is set, then the property will return the undef value and will bypass the C<validation> sub.

=item validation

You can set a code reference to validate a new value. If you don't set any C<validation> option, no validation will be done on the assignment.

In the validation code, the object is passed in C<$_[0]> and the value to be
validated is passed in C<$_[1]> and for regexing convenience it is aliased in C<$_>. Assign to C<$_> in the validation code to change the actual imput value.

    # web color validation
    use Object::props { name       => 'web_color'
                        validation => sub { /^#[0-9A-F]{6}$/ }
                      }
    
    # this will uppercase all input value
    use Object::props { name       => 'uppercase_it'
                        validation => sub { $_ = uc }
                      }
    # this would croak
    $object->web_color = 'dark gray'
    
    # when used
    $object->uppercase_it = 'abc' # real value will be 'ABC'

The validation code should return true on success and false on failure. Croak explicitly if you don't like the default error message.

=item protected

Set this option to a true value and the property will be turned I<read-only> when used from outside its class or sub-classes. This allows you to normally read and set the property from your class but it will croak if your user tries to set it.

You can however force the protection and set the property from outside the class that implements it by setting $MyClass::force to a true value. (Substitute 'MyClass' with the actual name of your class).

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Object::props.

=head1 AUTHOR

Domizio Demichelis, <dd@4pro.net>.

=head1 COPYRIGHT

Copyright (c)2002 Domizio Demichelis. All Rights Reserved. This is free software; it may be used freely and redistributed for free providing this copyright header remains part of the software. You may not charge for the redistribution of this software. Selling this code without Domizio Demichelis' written permission is expressly forbidden.

This software may not be modified without first notifying the author (this is to enable me to track modifications). In all cases the copyright header should remain fully intact in all modifications.

This code is provided on an "As Is'' basis, without warranty, expressed or implied. The author disclaims all warranties with regard to this software, including all implied warranties of merchantability and fitness, in no event shall the author, be liable for any special, indirect or consequential damages or any damages whatsoever including but not limited to loss of use, data or profits. By using this software you agree to indemnify the author from any liability that might arise from it is use. Should this code prove defective, you assume the cost of any and all necessary repairs, servicing, correction and any other costs arising directly or indrectly from it is use.

The copyright notice must remain fully intact at all times. Use of this software or its output, constitutes acceptance of these terms.


=head1 BUGS

None known, but the module is not completely tested.

=head1 CREDITS

Thanks to Juerd Waalboer (http://search.cpan.org/author/JUERD) that with its I<Attribute::Property> inspired the creation of this distribution.


