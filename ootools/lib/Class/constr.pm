package Class::constr ;
$VERSION = 1.75 ;

# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use 5.006_001
; use strict
; use Carp
; $Carp::Internal{+__PACKAGE__}++

; sub import
   { my ($pkg, @args) = @_
   ; my $callpkg = caller
   ; $args[0] ||= {}
   ; foreach my $constr ( @args )
      { my $n = $$constr{name} || 'new'
 
      ; $$constr{init} &&= [ $$constr{init} ]
                           unless ref $$constr{init} eq 'ARRAY'
      ; no strict 'refs'
      ; *{"$callpkg\::$n"}
        = sub
           { &{$$constr{pre_process}} if defined $$constr{pre_process}
           ; my $c = shift
           ; my $class = ref($c) || $c 
           ; (@_ % 2) && croak qq(Odd number of arguments for "$class->$n")
         
           ; my $s = bless {}, $class
         
           # For copy constructors, get initial values from the object
           # on which the constructor was called. Values passed to the
           # constructor will override copied values.
           ; if ($$constr{copy} and ref $c) 
              { for my $key (keys %{$c})
                 { unshift(@_, $key => $c->{$key}) if defined($c->{$key})
                 }
              }

           # Set the initial values for the new object
           ; while ( my ($p, $v) = splice @_, 0, 2 )
              { if ($s->can($p))                # if accessor available, use it
                 { $s->$p( $v )
                 }
                else
                 { croak qq(No such property "$p")
                         unless $$constr{no_strict}
                 ; eval { $s->$p( $v ) }             # try AUTOLOAD
                 ; $@ && ( $$s{$p} = $v )            # no strict so just set it
                 }
              }
           # Execute any initializer methods
           ; if ( $$constr{init} )
              { foreach my $m ( @{$$constr{init}} )
                 # any initializer can cancel construction by undefining the 
                 # object. If this happens, no need to continue
                 { last unless defined($s) 
                 ; $s->$m(@_)
                 }
              }
           ; $s
           }#END sub
      }#END for $constr
   }#END import


; 1

__END__

=head1 NAME

Class::constr - Pragma to implement constructor methods

=head1 VERSION 1.75

Included in OOTools 1.75 distribution.

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
    
    # with options
    use Class::constr { name        => 'new_object' ,
                        pre_process => \&change_input
                        init        => [ qw( init1 init2 ) ] ,
                        no_strict   => 1
                      } ;
                    
    # init1 and init2 will be called at run-time

=head2 Usage

    # creates a new object and eventually validates
    # the properties if any validation property option is set
    my $object = MyClass->new(digits => '123');

=head1 DESCRIPTION

This pragma easily implements constructor methods for your class. Use it with C<Class::props> and C<Object::props> to automatically validate the input passed with C<new()>, or use the C<no_strict> option to accept unknown properties as well.

You can completely avoid to write the constructor by just using it and eventually declaring the name and the init methods to call.

B<IMPORTANT NOTE>: If you write any script that rely on this module, you better send me an e-mail so I will inform you in advance about eventual planned changes, new releases, and other relevant issues that could speed-up your work.

=head2 Examples

If you want to see some working example of this distribution, take a look at the source of the modules of the F<CGI-Application-Plus> distribution, and the F<Template-Magic> distribution.

=head1 OPTIONS

=head2 name

The name of the constructor method. If you omit this option the 'new' name will be used by default.

=head2 no_strict

With C<no_strict> option set to a true value, the constructor method accepts and sets also unknown properties (i.e. not predeclared). You have to access the unknown properties without any accessor method. All the other options will work as expected. Without this option the constructor will croak if any property does not have an accessor method.

=head2 pre_process

You can set a code reference to preprocess @_.

The original C<@_> is passed to the referenced pre_process CODE. Modify C<@_> in the CODE to change the actual input value.

    # This code will transform the @_ on input
    # if it's passed a ref to an ARRAY
    # [ qw|a b c| ] will become
    # ( a=>'a', b=>'b', c=>'c')
    
    use Class::constr
        { name       => 'new'
        , pre_process=> sub
                         { if ( ref $_[1] eq 'ARRAY' )
                            { $_[1] = { map { $_=>$_ } @{$_[1]} }
                            }
                         }
        }

=head2 init

Use this option if you want to call other methods in your class to further initialize the object. You can group methods by passing a reference to an array containing the method names.

After the assignation and validation of the properties, the initialization methods in the C<init> option will be called. Each init method will receive the blessed object passed in C<$_[0]> and the other parameters in the remaining C<@_>.

Any C<init> method can cancel construction of the object by undefining C<$_[0]>. This will cause the constructor to return undef. If you prefer, you can explicitly C<croak> from your init method.

   
   use Class::constr
      { name       => 'new'
      , init       => 'too_many'
      }
   ;
   sub too_many
      { if ( $MyClass::num_instances > $MyClass::max_instances)
         { $_[0] = undef # Do not allow new object to be returned
         }
        else
         { $MyClass::num_instances++
         }
      }
   

=head2 copy

If this option is set to a true value, the constructor will be a "copy constructor". Copy constructors allow you to create a new object that inherits data from an existing object. Values passed to the constructor will overwrite copied values, and C<init> methods will also have a chance to manipulate the values. 

B<Warning:> The copy constructor will only perform a I<shallow> copy, which means that after a copy any references stored in properties will point to the I<same> variable in I<both> objects (the objects will share a single variable instead of each having its own private copy). If you don't want this behavior, you should reset these properties in your C<init> method. Properties created by the Object::groups pragma are effected by this. Such properties should be explicitly set to C<undef> in your C<init> method for sane behavior.

Copy constructors may also be called as traditional class method constructors, but of course there will be no values to be copied into the new object. Generally, you will want to have a normal constructor to use when you don't need the copy functionality.

   package My::Class;
   use Class::constr
      ( { name       => 'new'
        , init       => '_init'
        }
      , { name       => 'copy_me'
        , copy       => 1
        , init       => '_init_copy' # Special init undefs properties
                                     # containing shared references
        }
      )
   
   # Then in your program somewhere
   my $obj = My::Class->new( property => 1); 
   my $copy = $obj->copy_me(); # $copy->property == 1
   

=head1 SUPPORT and FEEDBACK

If you need support or if you want just to send me some feedback or request, please use this link: http://perl.4pro.net/?Class::constr.

=head1 AUTHOR and COPYRIGHT

� 2004 by Domizio Demichelis.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

=head1 CREDITS

Thanks to Juerd Waalboer (L<http://search.cpan.org/author/JUERD>) that with its I<Attribute::Property> inspired the creation of this distribution.

Thanks to Vince Veselosky (L<(http://search.cpan.org/author/VESELOSKY)>) for his patches and improvement.

=cut

# vim:ft=perl:expandtab:sw=3:ts=3:
