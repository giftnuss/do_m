package Class::new ;
$VERSION = 1.2 ;

; use 5.006_001
; use strict
; use Carp

; use constant

{ START_SUB => q!
  sub
   { my $c = shift
   ; croak qq(Can't call method "$n" on a reference)
           if ref $c
   ; croak qq(Odd number of arguments for "$c->$n")
           if @_ % 2
   ; my $o = bless {}, $c
   ; while ( my ($p, $v) = splice @_, 0, 2 )
      { $o->can($p)
        or croak qq(No such property "$p")
      ; { local $Carp::Internal{+__PACKAGE__} = 1
        ; $o->$p( $v )
        }
      }
!
, INIT_LOOP => q!
   ; foreach my $m ( @{$args{init}} )
      { $o->$m(@_)
      }
!
, END_SUB => q!
   ; $o
   }
!
}

; sub import
   { my ($pkg, %args) = @_
   ; my $callpkg = caller
   ; my $n = $args{name} || 'new'
 
   ; $args{init} &&= [ $args{init} ]
                     unless ref $args{init} eq 'ARRAY'
   
   ###### SUB ######
   ; my $sub = START_SUB
   ;    $sub .= INIT_LOOP if $args{init}
   ;    $sub .= END_SUB
   ###### END SUB ######
   
   ; no strict 'refs'
   ; eval '*{"$callpkg\::$n"} ='. $sub
   ; print "### $n ###$sub\n" if $Base::OOTools::print_codes
   }


; 1

__END__

=head1 NAME

Class::new - Pragma to implement constructor methods

=head1 VERSION 1.2

Included in OOTools 1.2 distribution. The distribution includes:

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
    
    # with options
    use Class::new  name  => 'new_object'
                    init  => [ qw( init1 init2 ) ] ;
                    
    # init1 and init2 will be called at run-time
    
=head2 Usage

    # creates a new object and eventually validates
    # the properties if any validation property option is set
    my $object = MyClass->new(digits => '123');
                                 
=head1 DESCRIPTION

This pragma easily implements lvalue constructor methods for your class. Use it with C<Class::props> and C<Object::props> to automatically validate the input passed with C<new()>

You can completely avoid to write the constructor by just using it and eventually declaring the name and the init methods to call.

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

=item init

Use this option if you want to call other method in your class to further initialize the object. You can group methods by passing a reference to an array containing the method names.

After the assignation and validation of the properties, the initialization methods in the C<init> option will be called. Each init method will receive the blessed object passed in C<$_[0]> and the other (original) parameter in the remaining C<@_>.

=back

=head1 SUPPORT and FEEDBACK

I would like to have just a line of feedback from everybody who tries or actually uses this module. PLEASE, write me any comment, suggestion or request. ;-)

More information at http://perl.4pro.net/?Class::new.

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

