package Object::group ;
$VERSION = 1.4 ;

use base 'Class::group' ;
   
1 ;

__END__

=head1 NAME

Object::group - Pragma to implement group of properties

=head1 VERSION 1.4

Included in OOTools 1.4 distribution. The distribution includes:

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
    
    # creates constructor method
    use Class::costr ;
    
    # implement group method without options
    use Object::group { name  => 'myGroup' ,
                        props => [qw(prop1 prop2)]
                      } ;
    
    # with options
    use Object::group { name      => 'myOtherGroup' ,
                        no_strict => 1  ;
                        props => [ { name    => [qw(prop3 prop4)] ,
                                     default => 'something'
                                   }
                                 ]
                      } ;

=head2 Usage

    my $object = MyClass->new ;
    
    $object->myGroup( prop1 => 1 ,
                      prop2 => 2 ) ;
    
    my @keys     = $object->myGroup
    my $hash_ref = $object->myGroup
    
    my $value = $object->prop2 ;             # $value == 2
       $value = $object->myGroup('prop2') ;  # $value == 2
       $value = $hash_ref->{prop2} ;         # $value == 2
       $value = $object->{myGroup}{prop2} ;  # $value == 2
    
    # the default will initialize the hash reference
    my $other_hash_ref = $object->myOtherGroup
       $value = $other_hash_ref->{prop3}     # $value eq 'something'
       
    # adding a unknow property (see no_strict)
    $object->myOtherGroup(prop5 => 5) ;

=head1 DESCRIPTION

This pragma easily implements accessor methods for group of properties.

It creates an accessor method for each property in the C<props> option as you where using the L<Object::props|Object::props> pragma, and creates an accessor method for the group.

B<Note>: The grouped properties will be stored in e.g. C<$Object->{group}{property}> instead of the usual C<$Object->{property}>

Whit the accessor method for the group you can:

=over

=item *

set a group of properties by passing an hash of values to the accessor

=item *

retrieve (in list context) the list of the names of the (already defined) properties of the group

=item *

retrieve (in scalar context) the reference to the underlying hash containing the grouped properties.

=back

B<Note>: The underlaying hash contains:

=over

=item *

all the already set properties of the class and base classes

=item *

all the properties with a C<default> or C<rt_default> option (of the class and base classes, even if they have not been set yet)

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

=head2 OPTIONS

=over

=item name

The name of the group method.

=item no_strict

With C<no_strict> option set to a true value, the method accepts and sets also unknown properties (i.e. not predeclared). You have to access the unknown properties without any accessor method. All the other options will work as expected. Without this option the method will croak if any property does not have an accessor method.

=item props

This option creates the same properties accessor methods as you would use directly the L<Object::props|Object::props> pragma. It accepts a reference to an array, containing the same structured parameters as such accepted by the L<Object::props|Object::props> pragma.

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Object::group.

=head1 AUTHOR and COPYRIGHT

© 2003 by Domizio Demichelis <dd@4pro.net>.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

=head1 CREDITS

Thanks to Juerd Waalboer (http://search.cpan.org/author/JUERD) that with its I<Attribute::Property> inspired the creation of this distribution.

