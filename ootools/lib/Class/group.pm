package Class::group ;
$VERSION = 1.31 ;

; use base 'Class::props'
; use strict
; use Carp


; use constant START_SUB => q!
  sub
   { my $s = shift
!
; use constant AUTO_INIT => q!
   ; $init->($s, ref $s||$s)
!
; use constant CLASS => q!
   ; my $hash = \%{(ref $s||$s)."::$gr"}
!
; use constant OBJECT => q!
   ; my $hash = $$s{$gr}
!
; use constant END_SUB => q!
   ; return $$hash{$_[0]} if @_ == 1
   ; croak qq(Odd number of arguments for "$gr")
           if @_ % 2
   ; while ( my ($p, $v) = splice @_, 0, 2 )
      { if ( $$group{no_strict} )
         { $$hash{$p} = $v
         }
        else
         { $s->can($p)
           or croak qq(No such property "$p")
         ; $s->$p( $v )
         }
      }
   ; wantarray
     ? keys %$hash
     : $hash || $$s{$gr}  # rare perl bug?
   }
!

; sub import
   { my ( $pkg, @args ) = @_
   ; my $callpkg = caller
   ; my $group = { @args }
   ; my $gr   = $$group{name}
   ; croak qq(Group "$gr" already defined in package "$callpkg")
           if defined &{"$callpkg\::$gr"}
   ; my @default_prop
   ; foreach my $prop ( @{$$group{props}} )
      { $prop = $pkg->_init_prop_param( $prop )
      ; if (  defined $$prop{default}
           || defined $$prop{rt_default}
           )
         { push @default_prop, @{$$prop{name}}
         }
      ; $$prop{group} = $gr
      ; $pkg->_create_prop( $prop, $callpkg )
      }
   ; no strict 'refs'
   ; my $init
   ; if ( @default_prop )
      { ${"$pkg\::DEFAULT_PROP"}{$callpkg}{$gr} = \@default_prop
      ; $init = sub
                 { foreach my $p ( @{ ${"$pkg\::DEFAULT_PROP"}{$_[1]}{$gr} } )
                    { $_[0]->$p
                    }
                 ; foreach my $c ( @{"$_[1]\::ISA"} )
                    { $init->($_[0], $c)
                    }
                 }
      }
                                               
   ; my $sub  = START_SUB
   ;    $sub .= $pkg =~ /^Class/
                ? CLASS
                : OBJECT
   ;    $sub .= @default_prop
                ? AUTO_INIT
                : ''
   ;    $sub .= END_SUB
#   ; print qq(### $callpkg\::$gr ###$sub\n)
   ; eval '*{"$callpkg\::$gr"} = '. $sub
#   ; if ( $@ )
#      { croak qq(Error in group sub: $@\n)
#            . qq(### $callpkg\::$gr ###$sub\n)
#      }
   }
1 ;

__END__

=head1 NAME

Class::group - Pragma to implement group of properties

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
    
    # implement group method without options
    use Class::group name  => 'myGroup' ,
                     props => [qw(prop1 prop2)] ;
    
    # with options
    use Class::group name      => 'myOtherGroup' ,
                     no_strict => 1 ,
                     props     => [ { name    => [qw(prop3 prop4)] ,
                                      default => 'something'
                                    }
                                  ] ;

=head2 Usage

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

This option creates the same properties accessor methods as you would use directly the L<Class::props|Class::props> pragma. It accepts a reference to an array, containing the same structured parameters as such accepted by the L<Class::props|Class::props> pragma.

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Class::group.

=head1 AUTHOR and COPYRIGHT

© 2003 by Domizio Demichelis <dd@4pro.net>.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

=head1 CREDITS

Thanks to Juerd Waalboer (http://search.cpan.org/author/JUERD) that with its I<Attribute::Property> inspired the creation of this distribution.

