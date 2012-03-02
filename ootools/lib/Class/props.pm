package Class::props ;
$VERSION = 1.31 ;


; use 5.006_001
; use strict
; use Carp

; use constant START_SUB => q!
  sub : lvalue
   { croak qq(Too many arguments for "$n" property)
           if @_ > 2
!
; use constant P_CLASS => q!
   ; my $scalar = \${(ref $_[0]||$_[0])."::$n"}
!
; use constant G_CLASS => q!
   ; my $scalar = \${(ref $_[0]||$_[0])."::$gr"}{$n}
!
; use constant P_OBJECT => q!
   ; croak qq(Wrong value type passed to "$n" object property)
           unless ref $_[0]
   ; my $scalar = \$_[0]{$n}
!
; use constant G_OBJECT => q!
   ; croak qq(Wrong value type passed to "$n" object property)
           unless ref $_[0]
   ; my $scalar = \$_[0]{$gr}{$n}
!
; use constant TIE => q!
   ; unless ( tied $$scalar )
      { tie $$scalar
          , $pkg
          , $_[0]
          , $n
          , $scalar
          , $$prop{default}
          , $$prop{rt_default}
          , $$prop{protected}
          , $$prop{validation}
      }
!
; use constant END_SUB => q!
   ; @_ == 2
     ? ( $$scalar = $_[1] )
     :   $$scalar
   }
!

  
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
   ; if (  $$prop{default}
        && $$prop{rt_default}
        )
      { croak qq("default" and "rt_default" options are incompatible)
      }
   ; $prop
   }

; sub _create_prop
   { my $callpkg = pop
   ; my ( $pkg, $prop ) = @_
   ; my $gr = $$prop{group}
   ; foreach my $n ( @{$$prop{name}} )       # foreach property
      { croak qq(Property "$n" already defined in package "$callpkg")
              if defined &{"$callpkg\::$n"}
      ; my $sub  = START_SUB
      ;    $sub .= $pkg =~ /^Class/
                   ? $gr
                     ? G_CLASS
                     : P_CLASS
                   : $gr
                     ? G_OBJECT
                     : P_OBJECT
      ;    $sub .= TIE if defined $$prop{validation}
                       or defined $$prop{default}
                       or defined $$prop{rt_default}
                       or defined $$prop{protected}
      ;    $sub .= END_SUB
      ; no strict 'refs'
#      ; print qq(### $callpkg\::$n ###$sub\n)
      ; eval '*{"$callpkg\::$n"} = '. $sub
#      ; if ( $@ )
#         { croak qq(Error in props sub: $@\n)
#               . qq(### $callpkg\::$n ###$sub\n)
#         }
      }
   }
 

      
# [0] object/class
# [1] prop name
# [2] lvalue ref
# [3] default
# [4] rt_default
# [5] protected
# [6] validation subref

; sub TIESCALAR
   { bless \@_, shift
   }
   
; sub FETCH
   { return ${$_[0][2]} if defined ${$_[0][2]}
   ; if (defined $_[0][3])                      # default
      { $_[0]->STORE( $_[0][3] )
      }
     elsif (defined $_[0][4])                   # rt_default
      { $_[0]->STORE( $_[0][4]( $_[0][0] ) )
      }
   }

; sub STORE
   { my $from_FETCH = (caller(1))[3]
                   && (caller(1))[3] =~ /::FETCH$/
   ; my $default = $from_FETCH
                   ? 'default '
                   : ''
   ; if (   $_[0][5]            # if protected
        &&! $from_FETCH         # bypass for default
        &&! our $force          # bypass deliberately
        )
      { my ($OK, $f)
      ; until ( $OK )
         { last unless my $caller = caller($f++)
         ; $OK = $caller->can($_[0][1])
         }
        ; croak qq("$_[0][1]" is a read-only property)
          unless $OK
      }
   ; local $_ = $_[1]
   ; if ( defined $_[0][6]     # validation subref
        && defined $_          # bypass for undef (reset to default)
        )
      { $_[0][6]( $_[0][0], $_)
        or croak qq(Invalid ${default}value for "$_[0][1]" property)
      }
   ; ${$_[0][2]} = $_
   }
   

1 ;

__END__

=head1 NAME

Class::props - Pragma to implement lvalue accessors with options

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
    
    # just accessors without options (list of strings)
    use Class::props @prop_names ;                       # @prop_names (1)
    
    # a property with validation and default (list of hash refs)
    use Class::props { name       => 'digits',
                       validation => sub{ /^\d+\z/ }     # just digits
                       default    => 10
                     } ;
    
    # a group of properties with common full options
    use Class::props { name       => \@prop_names2,      # @prop_names2 (1)
                       rt_default => sub{$_[0]->other_default} ,
                       validation => sub{ /\w+/ }
                       protected  => 1
                     } ;
                     
    # all the above in just one step (list of strings and hash refs)
    use Class::props @prop_names ,                       # @prop_names (1)
                     { name       => 'digits',
                       validation => sub{ /^\d+\z/ }
                       default    => 10
                     } ,
                     { name       => \@prop_names2,      # @prop_names2 (1)
                       rt_default => sub{$_[0]->other_default} ,
                       validation => sub{ /\w+/ }
                       protected  => 1
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

The accessor method creates a scalar in the class that implements it (e.g. $Class::property) and ties it to the options you set, so even if you access the scalar without using the accessor, the options will have effect.

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

=item default

Use this option to set a I<default value>. If any C<validation> option is set, then the I<default value> is validated as well.
You can reset a property to its default value by assigning it the undef value.

B<Note>:  C<default> and  C<rt_default> are incompatible options: the module will croak if you try to use both for the same property.

=item rt_default

Almost the same as the C<default> option, but it accepts a code references that will be executed at run-time and should return the default value ('rt' stands for 'run time'). The referenced code will receive the same C<@_> parameters that the property accessor method recieves.

B<Note>:  C<default> and  C<rt_default> are incompatible options: the module will croak if you try to use both for the same property.

=item validation

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

=item protected

Set this option to a true value and the property will be turned I<read-only> when used from outside its class or sub-classes. This allows you to normally read and set the property from your class but it will croak if your user tries to set it.

You can however force the protection and set the property from outside the class that implements it by setting $Base::OOTools::force to a true value.

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Class::props.

=head1 AUTHOR and COPYRIGHT

© 2003 by Domizio Demichelis <dd@4pro.net>.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.


=head1 CREDITS

Thanks to Juerd Waalboer (http://search.cpan.org/author/JUERD) that with its I<Attribute::Property> inspired the creation of this distribution.


