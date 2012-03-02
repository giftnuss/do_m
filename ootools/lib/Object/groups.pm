package Object::groups ;
$VERSION = 1.6 ;

use base 'Class::groups' ;
   
1 ;

__END__

=head1 NAME

Object::groups - Pragma to implement group of properties

=head1 VERSION 1.54

Included in OOTools 1.54 distribution. The distribution includes:

=over

=item * Class::constr

Pragma to implement constructor methods

=item * Class::props

Pragma to implement lvalue accessors with options

=item * Class::groups

Pragma to implement groups of properties accessors with options

=item * Object::props

Pragma to implement lvalue accessors with options

=item * Object::groups

Pragma to implement groups of properties accessors with options

=back

=head1 SYNOPSIS

=head2 Class

    package MyClass ;
    
    # creates constructor method
    use Class::costr ;
    
    # implement group method without options
    use Object::groups { name  => 'myGroup' ,
                         props => [qw(prop1 prop2)]
                       } ;
    
    # with options
    use Object::groups
        { name      => 'myOtherGroup' ,
          no_strict => 1 ,
          default   => { aProp => 'some value' } ,
          pre_process=> sub
                         { if ( ref $_[1] eq 'ARRAY' )
                            { $_[1] = { map { $_=>$_ } @{$_[1]} }
                            }
                         } ,
          props     => [ { name    => [qw(prop3 prop4)] ,
                           default => 'something'
                         }
                       ]
        } ;

=head2 Usage

    my $object = MyClass->new ;
    
    $object->myGroup(\%hash) ;

    # same thing
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

B<IMPORTANT NOTE>: If you write any script that rely on this module, you better send me an e-mail so I will inform you in advance about eventual planned changes, new releases, and other relevant issues that could speed-up your work. (see also L<"CONTRIBUTION">) 

=head2 Examples

If you want to see some working example of this distribution, take a look at the source of the modules of the F<CGI-Application-Plus> distribution, and the F<Template-Magic> distribution.

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

=item pre_process

You can set a code reference to preprocess @_.

The original <@_> is passed to the referenced pre_process CODE. Modify C<@_> in the CODE to change the actual input value.

    # This code will transform the @_ on input
    # if it's passed a ref to an ARRAY
    # [ qw|a b c| ] will become
    # ( a=>'a', b=>'b', c=>'c')
    
    use Object::groups
        { name       => 'myGroup'
        , pre_process=> sub
                         { if ( ref $_[1] eq 'ARRAY' )
                            { $_[1] = { map { $_=>$_ } @{$_[1]} }
                            }
                         ; 1
                         }
        }

=item default

Use this option to set a I<default value>. The I<default value> must be a HASH reference or a CODE reference. If it is a Code reference it will be evaluated at runtime and the property will be set to the HASH reference that the referenced CODE must return.

You can reset a property to its default value by assigning an empty HASH reference ({}) to it.

=item props

This option creates the same properties accessor methods as you would use directly the L<Object::props|Object::props> pragma. It accepts a reference to an array, containing the same structured parameters as such accepted by the L<Object::props|Object::props> pragma.

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Object::group.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

=head1 CREDITS

Thanks to Juerd Waalboer (http://search.cpan.org/author/JUERD) that with its I<Attribute::Property> inspired the creation of this distribution.

=head1 CONTRIBUTION

I always answer to each and all the message i receive from users, but I have almost no time to find, install and organize a mailing list software that could improve a lot the support to people that use my modules. Besides I have too little time to write more detailed documentation, more examples and tests. Your contribution would be precious, so if you can and want to help, just contact me. Thank you in advance.
