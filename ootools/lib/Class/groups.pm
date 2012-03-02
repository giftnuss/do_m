package Class::groups ;
$VERSION = 1.51 ;

; use 5.006_001
; use base 'Class::props'
; use strict
; use Carp

; sub import
   { my ( $pkg, @args ) = @_
   ; my $callpkg = caller
   ; foreach my $group ( @args )
      { $$group{name} = [ $$group{name} ]
                        unless ref $$group{name} eq 'ARRAY'
      ; foreach my $n ( @{$$group{name}} )
         { croak qq(Group "$n" already defined in package "$callpkg")
                 if defined &{"$callpkg\::$n"}
         ; my @default_prop
         ; foreach my $prop ( @{$$group{props}} )
            { $prop = $pkg->_init_prop_param( $prop )
            ; if (  defined $$prop{default} )
               { push @default_prop, @{$$prop{name}}
               }
            ; $$prop{group} = $n
            ; $pkg->_create_prop( $prop, $callpkg )
            }
         ; no strict 'refs'
         ; my $init
         ; if ( @default_prop )
            { ${"$pkg\::D_PROPS"}{$callpkg}{$n} = \@default_prop
            ; $init = sub
                       { foreach my $p ( @{ ${"$pkg\::D_PROPS"}
                                             {$_[1]}
                                             {$n}
                                          }
                                       )
                          { $_[0]->$p
                          }
                       ; foreach my $c ( @{"$_[1]\::ISA"} )
                          { $init->($_[0], $c)
                          }
                       }
            }
         ; *{"$callpkg\::$n"}
           = sub
              { &{$$group{pre_process}} if defined $$group{pre_process}
              ; my $s = shift
              ; my $hash = $pkg =~ /^Class/
                           ? \%{(ref $s||$s)."::$n"}      # class
                           : ( $$s{$n} ||= {} )           # object
              ; my $data
              ; if ( @_ )
                 { if ( ref $_[0] eq 'HASH' )
                    { $data = $_[0]
                    }
                   elsif ( @_ == 1 )
                    { return $$hash{$_[0]}
                    }
                   elsif ( not ( @_ % 2 ) )
                    { $data = { @_ }
                    }
                   else
                    { croak qq(Odd number of arguments for "$n")
                    }
                 ; while ( my ($p, $v) = each %$data )
                    { if ( $$group{no_strict} )               #no_strict
                       { $$hash{$p} = $v
                       }
                      else                                    # strict
                       { $s->can($p)
                         or croak qq(No such property "$p")
                       ; $s->$p( $v )
                       }
                    }
                 }
              ; $init->($s, ref $s||$s) if @default_prop   # init defaults
              ; wantarray
                ? keys %$hash
                : $hash
              }

         }
      }
   }
   
1 ;

__END__

=head1 NAME

Class::group - Pragma to implement group of properties

=head1 VERSION 1.51

Included in OOTools 1.51 distribution. The distribution includes:

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
    
    # implement group method without options
    use Class::group { name  => 'myGroup' ,
                       props => [qw(prop1 prop2)]
                     } ;
    
    # with options
    use Class::group
        { name      => 'myOtherGroup' ,
          no_strict => 1 ,
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

    MyClass->myGroup(\%hash) ;
    
    # same thing
    MyClass->myGroup( prop1 => 1 ,
                      prop2 => 2 ) ;
       
    my @keys     = MyClass->myGroup
    my $hash_ref = MyClass->myGroup
    
    my $value = MyClass->prop2 ;             # $value == 2
       $value = MyClass->myGroup('prop2') ;  # $value == 2
       $value = $hash_ref->{prop2} ;         # $value == 2
       $value = $MyClass::myGroup{prop2} ;   # $value == 2
    
    # the default will initialize the hash reference
    my $other_hash_ref = MyClass->myOtherGroup
       $value = $other_hash_ref->{prop3}     # $value eq 'something'
    
    # adding a unknow property (see no_strict)
    MyClass->myOtherGroup(prop5 => 5) ;

=head1 DESCRIPTION

This pragma easily implements accessor methods for group of properties.

It creates an accessor method for each property in the C<props> option as you where using the L<Class::props|Class::props> pragma, and creates an accessor method for the group.

B<Note>: The grouped properties will be stored in e.g. C<$Class::group{property}> instead of the usual C<$Class::property>

With the accessor method for the group you can:

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

all the properties with a C<default> option (of the class and base classes, even if they have not been set yet)

=back

B<IMPORTANT NOTE>: If you write any script that rely on this module, you better send me an e-mail so I will inform you in advance about eventual planned changes, new releases, and other relevant issues that could speed-up your work. (see also L<"CONTRIBUTION">)

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
    
    use Class::groups
        { name       => 'myGroup' ,
          pre_process=> sub
                         { if ( ref $_[1] eq 'ARRAY' )
                            { $_[1] = { map { $_=>$_ } @{$_[1]} }
                            }
                         }
        }

=item props

This option creates the same properties accessor methods as you would use directly the L<Class::props|Class::props> pragma. It accepts a reference to an array, containing the same structured parameters as such accepted by the L<Class::props|Class::props> pragma.

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Class::group.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis <dd@4pro.net>.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

=head1 CREDITS

Thanks to Juerd Waalboer (http://search.cpan.org/author/JUERD) that with its I<Attribute::Property> inspired the creation of this distribution.

=head1 CONTRIBUTION

I always answer to each and all the message i receive from users, but I have almost no time to find, install and organize a mailing list software that could improve a lot the support to people that use my modules. Besides I have too little time to write more detailed documentation, more examples and tests. Your contribution would be precious, so if you can and want to help, just contact me. Thank you in advance.


