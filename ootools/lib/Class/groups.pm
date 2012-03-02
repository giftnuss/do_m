package Class::groups ;
$VERSION = 1.78 ;

# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use 5.006_001
; use base 'Class::props'
; use strict
; use Carp
; $Carp::Internal{+__PACKAGE__}++

; sub import
   { my $tool = shift
   ; $tool->add_to(scalar caller, @_)
   }

; sub add_to
   { my ( $tool, $pkg, @args ) = @_
   ; foreach my $group ( @args )
      { $group = { name => $group }
                 unless ref $group eq 'HASH'
      ; $$group{name} = [ $$group{name} ]
                        unless ref $$group{name} eq 'ARRAY'
      ; foreach my $n ( @{$$group{name}} )
         { if (  not(defined $$group{no_strict})
              && not(defined $$group{props})
              )
            { $$group{no_strict} = 1
            }
         ; my @group_props
         ; foreach my $prop ( @{$$group{props}} )
            { $prop = $tool->_init_prop_param( $prop )
            ; push @group_props, @{$$prop{name}}
            ; $$prop{group} = $n
            ; $tool->_add_prop($pkg, $prop )
            }
         ; no strict 'refs'
         ; my $init
         ; if ( @group_props )
            { ${"$tool\::PROPS"}{$pkg}{$n} = \@group_props
            ; $init = sub
                       { foreach my $p ( @{ ${"$tool\::PROPS"}
                                             {$_[1]}
                                             {$n}
                                          }
                                       )
                          { my $dummy = $_[0]->$p
                          }
                       ; foreach my $c ( @{"$_[1]\::ISA"} )
                          { $init->($_[0], $c)
                          }
                       }
            }
         ; *{"$pkg\::$n"}
           = sub
              { &{$$group{pre_process}} if defined $$group{pre_process}
              ; my $s = shift
              ; my $hash = $tool =~ /^Class/
                           ? \%{(ref $s||$s)."::$n"}      # class
                           : ( $$s{$n} ||= {} )           # object
              ; if (  ( my $def = $$group{default} )
                   && not keys %$hash
                   )
                 { my $dprops
                   =  ref $def eq 'HASH' && $def
                   || (ref $def eq 'CODE' || not ref $def) && $s->$def()
                 ; ref $dprops eq 'HASH' or croak
                   qq(Invalid "default" option for "$$group{name}[0]", died)
                 ; %$hash = %$dprops
                 }
              ; if ($init)
                 { $init->($s, ref($s)||$s)    # init defaults
                 ; undef $init
                 }
              ; my $data
              ; if ( @_ )
                 { if ( ref $_[0] eq 'HASH' ) # set
                    { $data = $_[0]
                    }
                   elsif ( @_ == 1 )          # get
                    { my @val
                    ; my @pro = ref $_[0] eq 'ARRAY' ? @{$_[0]} : $_[0]
                    ; foreach my $p ( @pro )
                       { if ( my $m = $s->can($p)
                              and grep /^$p$/, @group_props
                            )
                          { push @val, $s->$m
                          }
                         else
                          { if ( $$group{no_strict} )
                             { push @val, $$hash{$p}
                             }
                            else
                             { croak qq(No such property "$p", died)
                             }
                          }
                       }
                    ; return wantarray ? @val : $val[0]
                    }
                   elsif ( not ( @_ % 2 ) )  # set
                    { $data = { @_ }
                    }
                   else
                    { croak qq(Odd number of arguments for "$n", died)
                    }
                 ; while ( my ($p, $v) = each %$data )  # set
                    { if ( my $m = $s->can($p) )
                       { $s->$m($v)
                       }
                      else
                       { if ( $$group{no_strict} )
                          { $$hash{$p} = $v
                          }
                         else
                          { croak qq(No such property "$p", died)
                          }
                       }
                    }
                 }
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

Class::groups - Pragma to implement group of properties

=head1 VERSION 1.78

Included in OOTools 1.78 distribution.

The latest versions changes are reported in the F<Changes> file in this distribution.

The distribution includes:

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

=head2 Class

    package MyClass ;
    
    # implement group method without options
    use Class::groups qw(this that) ;

    # implement group method with properties
    use Class::groups { name  => 'myGroup' ,
                        props => [qw(prop1 prop2)]
                      } ;
    
    # with options
    use Class::groups
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

    MyClass->myGroup(\%hash) ;
    
    # same thing
    MyClass->myGroup( prop1 => 1 ,
                      prop2 => 2 ) ;
       
    $hash_ref = MyClass->myGroup
    
    $value = MyClass->prop2 ;             # $value == 2
    $value = MyClass->myGroup('prop2') ;  # $value == 2
    $value = $MyClass::myGroup{prop2} ;   # $value == 2
    $value = $$hash_ref{prop2} ;          # $value == 2
    
    ($p1, $p2) = MyClass->myGroup(['prop1','prop2']) ;
    
    # the default will initialize the hash reference
    $other_hash_ref = MyClass->myOtherGroup
    $value = $other_hash_ref->{prop3}     # $value eq 'something'
    
    # adding an unknow property (see no_strict)
    MyClass->myOtherGroup(prop5 => 5) ;

=head1 WARNING

Don't use the group accessor in list context in order to retrieve the hash keys. It is deprecated and it will return the whole hash in a future version.

    # deprecated
    @keys     = MyClass->myGroup ;
    
    # change it with
    @keys     = keys %{MyClass->myGroup} ;
    
    # future behaviour in list context
    %hash = MyClass->myGroup ;

=head1 DESCRIPTION

This pragma easily implements accessor methods for group of properties, which are very efficient function templates that your modules may import at compile time. "This technique saves on both compile time and memory use, and is less error-prone as well, since syntax checks happen at compile time." (quoted from "Function Templates" in the F<perlref> manpage).

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

all the properties with a I<default> option (of the class and base classes, even if they have not been set yet)

=back

B<IMPORTANT NOTE>: If you write any script that rely on this module, you better send me an e-mail so I will inform you in advance about eventual planned changes, new releases, and other relevant issues that could speed-up your work.

=head2 Examples

If you want to see some working example of this module, take a look at the source of my other distributions.

=head1 OPTIONS

=over

=head2 name => $name

The name of the group accessor.

=head2 no_strict => 0 | 1

With C<no_strict> option set to a true value, the accessor accepts and sets also unknown properties (i.e. not predeclared). You have to access the unknown properties without any accessor method. All the other options will work as expected. Without this option the method will croak if any property does not have an accessor method.

B<Note>: This option is on by default if you define an accessor group without any C<props> option (i.e. in this case you can omit the 'no_strict' option).

=head2 pre_process => \&code

You can set a code reference to preprocess @_.

The original C<@_> is passed to the referenced pre_process CODE. Modify C<@_> in the CODE to change the actual input value.

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

=head2 default => \%props | \&$method

Use this option to set a I<default value>. The I<default value> must be a HASH reference or a CODE reference. If it is a CODE reference it will be evaluated at runtime and the property will be set to the HASH reference that the referenced CODE must return.

You can reset a property to its default value by assigning an empty HASH reference ({}) to it.

=head2 props => \@props

This option creates the same properties accessor methods as you would use directly the L<Class::props|Class::props> pragma. It accepts a reference to an array, containing the same structured parameters as such accepted by the L<Class::props|Class::props> pragma.

=head1 METHODS

=head2 add_to( package, groups )

This will add to the package I<package> the accessors for the I<groups>. It is useful to add properties in other packages.

   package Any::Package;
   Class::groups->('My::Package', { name => 'any_name', ... });
   
   # which has the same effect of
   package My::Package;
   use Class::groups { name => 'any_name', ... }

=head1 SUPPORT and FEEDBACK

If you need support or if you want just to send me some feedback or request, please use this link: http://perl.4pro.net/?Class::groups.

=head1 AUTHOR and COPYRIGHT

� 2004-2005 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

=head1 CREDITS

Thanks to Juerd Waalboer (http://search.cpan.org/author/JUERD) that with its I<Attribute::Property> inspired the creation of this distribution.


