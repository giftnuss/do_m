package Class::props ;
$VERSION = 1.72 ;


; use 5.006_001
; use strict
; use Carp
; $Carp::Internal{+__PACKAGE__}++

; sub import
   { my ($pkg, @args) = @_
   ; my $callpkg = caller
   ; foreach my $prop ( @args )
      { $prop = $pkg->_init_prop_param( $prop )
      ; $pkg->_create_prop( $prop, $callpkg )
      }
   }

; sub _init_prop_param
   { my ( $pkg, $prop ) = @_
   ; $prop = { name => $prop }
             unless ref $prop eq 'HASH'
   ; $$prop{name} = [ $$prop{name} ]
                    unless ref $$prop{name} eq 'ARRAY'
   ; $$prop{allowed} &&= [ $$prop{allowed} ]
                         unless ref $$prop{allowed} eq 'ARRAY'
   ; $prop
   }
                      
; sub _create_prop 
   { my $callpkg = pop
   ; my ( $pkg, $prop ) = @_
   ; my $gr = delete $$prop{group}
   ; my $to_tie = (  defined $$prop{default}
                  || defined $$prop{protected}
                  || defined $$prop{allowed}
                  || defined $$prop{validation}
                  )
   ; foreach my $n ( @{$$prop{name}} )     # foreach property
      { no strict 'refs'
      ; *{"$callpkg\::$n"}
        = sub ($;$) : lvalue
           { (@_ > 2) && croak qq(Too many arguments for "$n" property)
           ;  my $scalar = $pkg =~ /^Class/
                           ? $gr
                             ? \${(ref $_[0]||$_[0])."::$gr"}{$n}
                             : \${(ref $_[0]||$_[0])."::$n"}
                           : $gr
                             ? \$_[0]{$gr}{$n}
                             : \$_[0]{$n}
           ; my $Tscalar
           ; if (   $to_tie
                )
              { tie $$Tscalar
                  , 'Class::props::Tie'
                  , $_[0]                   # [0] object/class
                  , $n                      # [1] prop name
                  , $scalar                 # [2] lvalue ref
                  , $prop                   # [3] options ref
              }
             else
              { $Tscalar = $scalar
              }
           ; @_ == 2
             ? ( $$Tscalar = $_[1] )
             :   $$Tscalar
           }
      }
   }

; package Class::props::Tie
; use Carp
; $Carp::Internal{+__PACKAGE__}++
; use strict

; sub TIESCALAR
   { bless \@_, shift
   }
   
; sub FETCH
   { if ( defined ${$_[0][2]} )
      { ${$_[0][2]}
      }
     elsif ( defined $_[0][3]{default} )          
      { my $def = ref $_[0][3]{default} eq 'CODE'
                  ? $_[0][3]{default}( $_[0][0] )
                  : $_[0][3]{default}
      ; $_[0][3]{no_strict}
        ? ${$_[0][2]} = $def
        : $_[0]->STORE( $def )
      }
     else
      { undef
      }
   }

; sub STORE
   { my $from_FETCH = (caller(1))[3]
                   && (caller(1))[3] =~ /::FETCH$/
   ; my $default = $from_FETCH
                   ? 'default '
                   : ''
   ; if (   $_[0][3]{protected}   # if protected
        &&! $from_FETCH           # bypass for default
        &&! $Class::props::force  # bypass deliberately
        )
      { my ($OK, $f)
      ; until ( $OK )
         { last unless my $caller = caller($f++)
         ; $OK = $caller->can($_[0][1])
         }
      ; $OK || croak qq("$_[0][1]" is a read-only property)
      }
   ; if (   $_[0][3]{allowed}     # if restricted
        &&! $from_FETCH           # bypass for default
        &&! $Class::props::force  # bypass deliberately
        )
      { my ($OK, $f)
      ; until ( $OK )
         { last unless my $caller = (caller($f++))[3]
         ; $OK = grep { $caller =~ qr/$_/ } @{$_[0][3]{allowed}}
         }
        ; $OK || croak qq("$_[0][1]" is a read-only property)
      }
   ; local $_ = $_[1]
   ; if ( defined $_[0][3]{validation}  # validation subref
        && defined $_                   # bypass for undef (reset to default)
        )
      { $_[0][3]{validation}( $_[0][0], $_)
        || croak qq(Invalid ${default}value for "$_[0][1]" property)
      }
   ; ${$_[0][2]} = $_
   }

1 ;

__END__

=head1 NAME

Class::props - Pragma to implement lvalue accessors with options

=head1 VERSION 1.72

Included in OOTools 1.72 distribution.

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
    
    # implement constructor without options
    use Class::constr ;
    
    # just accessors without options (list of strings)
    use Class::props @prop_names ;                       # @prop_names (1)
    
    # a property with validation and default (list of hash refs)
    use Class::props { name       => 'digits',
                       validation => sub{ /^\d+\z/ } ,    # just digits
                       default    => 10
                     } ;
    
    # a group of properties with common full options
    use Class::props { name       => \@prop_names2,      # @prop_names2 (1)
                       default    => sub{$_[0]->other_default} ,
                       validation => sub{ /\w+/ } ,
                       protected  => 1 ,
                       no_strict  => 1 ,
                       allowed    => qr/::allowed_sub$/
                     } ;
                     
    # all the above in just one step (list of strings and hash refs)
    use Class::props @prop_names ,                       # @prop_names (1)
                     { name       => 'digits',
                       validation => sub{ /^\d+\z/ } ,
                       default    => 10
                     } ,
                     { name       => \@prop_names2,      # @prop_names2 (1)
                       default    => sub{$_[0]->other_default} ,
                       validation => sub{ /\w+/ } ,
                       protected  => 1 ,
                       no_strict  => 1 ,
                       allowed    => qr/::allowed_sub$/
                     } ;
                     
    # (1) must be set in a BEGIN block to have effect at compile time

=head2 Usage

    my $object = MyClass->new(digits => '123');
    
    $object->digits    = '123';
    MyClass->digits    = '123';  # same thing
    
    $object->digits('123');      # old way supported
    
    my $d = $object->digits;     # $d == 123
       $d = $MyClass::digits     # $d == 123
    
    undef $object->digits        # $object->digits == 10 (default)
    
    # These would croak
    $object->digits    = "xyz";
    MyClass->digits    = "xyz";
    $MyClass::digits   = "xyz";

=head1 DESCRIPTION

This pragma easily implements lvalue accessor methods for the properties of your Class (I<lvalue> means that you can create a reference to it, assign to it and apply a regex to it).

You can completely avoid to write the accessor by just declaring the names and eventually the default value, validation code and other option of your properties.

The accessor method creates a scalar in the class that implements it (e.g. $Class::property) and access it using the options you set.

B<IMPORTANT NOTE>: Since the version 1.7 the options don't work if you access the scalar without using the accessor, so you can direct access to bypass the options.

=head2 Class properties vs Object properties

The main difference between C<Object::props> and C<Class::props> is that the first pragma creates instance properties related with the object and stored in $object->{property}, while the second pragma creates class properties related with the class and stored in $Class::property.

A Class property is accessible either through the class or through all the objects of that class, while an object property is accessible only through the object that set it.

   package MyClass;
   use Class::constr ;
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
   MyClass->class_prop2  = 200 ; # static method works as well
   
   print $object1->class_prop1 ; # would print 100
   print $object2->class_prop1 ; # would print 100
   print $object1->class_prop2 ; # would print 200
   print $object2->class_prop2 ; # would print 200

=head2 Examples

If you want to see some working example of this distribution, take a look at the source of the modules of the F<CGI-Application-Plus> distribution, and the F<Template-Magic> distribution.

=head1 OPTIONS

=head2 name

The name of the property is used as the identifier to create the accessor method, and the scalar that contains it.

Given 'my_prop' as the class property name:

    MyClass->my_prop = 10 ;  # assign 10 to $MyClass::my_prop
    MyClass->my_prop( 10 );  # assign 10 to $MyClass::my_prop
    
    # assuming $object is an object of class MyClass
    $object->my_prop = 10 ;  # assign 10 to $MyClass::my_prop
    $object->my_prop( 10 );  # assign 10 to $MyClass::my_prop
    
    # same thing if MyClass::constr is implemented
    # by the Class::constr pragma
    
    $object = MyClass->new( my_prop => 10 );

You can group properties that have the same set of option by passing a reference to an array containing the names. If you don't use any option you can pass a list of plain names as well. See L<"SYNOPSYS">.

=head2 default

Use this option to set a I<default value>. If any C<validation> option is set, then the I<default value> is validated as well (the C<no_strict> option override this).

If you pass a CODE reference as default it will be evaluated at runtime and the property will be set to the result of the referenced CODE.

You can reset a property to its default value by assigning it the undef value.

=head2 no_strict

With C<no_strict> option set to a true value, the C<default> value will not be validate even if a validation option is set. Without this option the method will croak if the C<default> are not valid.

=head2 validation

You can set a code reference to validate a new value. If you don't set any C<validation> option, no validation will be done on the assignment.

In the validation code, the object or class is passed in C<$_[0]> and the value to be validated is passed in C<$_[1]> and for regexing convenience it is aliased in C<$_>. Assign to C<$_> in the validation code to change the actual imput value.

    # web color validation
    use Class::props { name       => 'web_color'
                       validation => sub { /^#[0-9A-F]{6}$/ }
                     }
    
    # this will uppercase all input value
    use MyClass::props { name       => 'uppercase_it'
                         validation => sub { $_ = uc }
                       }
    # this would croak
    MyClass->web_color = 'dark gray'
    
    # when used
    MyClass->uppercase_it = 'abc' # actual value will be 'ABC'

The validation code should return true on success and false on failure. Croak explicitly if you don't like the default error message.

=head2 allowed

The property is settable only by the caller sub that matches with the content of this option. The content can be a compiled RE or a simple string that will be used to check the caller. (Pass an array ref for multiple items)

    use Class::props { name    => 'restricted'
                       allowed => [ qr/::allowed_sub1$/ ,
                                    qr/::allowed_sub2$/ ]
                     }

You can however force the assignation from not matching subs by setting $Class::props::force to a true value.

=head2 protected

Set this option to a true value and the property will be turned I<read-only> when used from outside its class or sub-classes. This allows you to normally read and set the property from your class but it will croak if your user tries to set it.

You can however force the protection and set the property from outside the class that implements it by setting $Class::props::force to a true value.


=head1 SUPPORT and FEEDBACK

If you need support or if you want just to send me some feedback or request, please use this link: http://perl.4pro.net/?Class::props.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

=head1 CREDITS

Thanks to Juerd Waalboer (http://search.cpan.org/author/JUERD) that with its I<Attribute::Property> inspired the creation of this distribution.
