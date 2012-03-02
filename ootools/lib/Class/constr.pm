package Class::constr ;
$VERSION = 1.51 ;

; use 5.006_001
; use strict
; use Carp

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
           ; ref($c)  && croak qq(Can't call method "$n" on a reference)
           ; (@_ % 2) && croak qq(Odd number of arguments for "$c->$n")
           ; my $s = bless {}, $c
           ; while ( my ($p, $v) = splice @_, 0, 2 )
              { unless ( $$constr{no_strict} )       # if strict
                 { $s->can($p)                       # and no method
                   || croak qq(No such property "$p")
                 }
              ; local $Carp::Internal{+__PACKAGE__} = 1
              ; eval { $s->$p( $v ) }                # if method or AUTOLOAD
              ; $@ && ( $$s{$p} = $v )               # anyway
              }
           ; if ( $$constr{init} )
              { foreach my $m ( @{$$constr{init}} )
                 { $s->$m(@_)
                 }
              }
           ; $s
           }
      }
   }


; 1

__END__

=head1 NAME

Class::constr - Pragma to implement constructor methods

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

This pragma easily implements lvalue constructor methods for your class. Use it with C<Class::props> and C<Object::props> to automatically validate the input passed with C<new()>, or use the C<no_strict> option to accept unknow properties as well.

You can completely avoid to write the constructor by just using it and eventually declaring the name and the init methods to call.

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

The name of the constructor method. If you omit this option the 'new' name will be used by default.

=item no_strict

With C<no_strict> option set to a true value, the constructor method accepts and sets also unknown properties (i.e. not predeclared). You have to access the unknown properties without any accessor method. All the other options will work as expected. Without this option the constructor will croak if any property does not have an accessor method.

=item pre_process

You can set a code reference to preprocess @_.

The original <@_> is passed to the referenced pre_process CODE. Modify C<@_> in the CODE to change the actual input value.

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

=item init

Use this option if you want to call other methods in your class to further initialize the object. You can group methods by passing a reference to an array containing the method names.

After the assignation and validation of the properties, the initialization methods in the C<init> option will be called. Each init method will receive the blessed object passed in C<$_[0]> and the other parameters in the remaining C<@_>.

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Class::constr.

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis <dd@4pro.net>.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

=head1 CREDITS

Thanks to Juerd Waalboer (http://search.cpan.org/author/JUERD) that with its I<Attribute::Property> inspired the creation of this distribution.

=head1 CONTRIBUTION

I always answer to each and all the message i receive from users, but I have almost no time to find, install and organize a mailing list software that could improve a lot the support to people that use my modules. Besides I have too little time to write more detailed documentation, more examples and tests. Your contribution would be precious, so if you can and want to help, just contact me. Thank you in advance.

