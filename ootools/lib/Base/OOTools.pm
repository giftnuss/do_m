package Base::OOTools ;
$VERSION = 1.12 ;

; use 5.006_001
; use strict
; use Carp

; use constant

{ START_SUB => q!
  sub : lvalue
   { croak qq(Too many arguments for "$n" property)
           if @_ > 2
!
, DECLARE_WRITE_PROTECTED => q!
   ; my $write_protected
!
, SET_CLASS => q!
   ; my $class = ref $_[0] || $_[0]
!
, CLASS => q!
   ; my $scalar = \${"$class\::$n"}
!
, OBJECT => q!
   ; croak qq(Wrong value type passed to "$n")
           unless ref $_[0]
   ; my $scalar = \$_[0]{$n}
!
, DEFAULT => q!
   ; $$scalar = $default
                unless defined $$scalar
!
, PROTECTED => q!
   ; unless ( ${"$class\::force"} )
      { my $caller = (caller)[0] eq 'Class::new'
                     ? (caller(1))[0]
                     : (caller)[0]
      ; $write_protected = $caller->can($n)
                           ? 0
                           : 1
      }
!
, TIE => q!
   ; tie $$scalar                     # scalar
       , $pkg                         # class
       , $_[0]                        # [0] object/class
       , $n                           # [1] prop name
       , $$item{validation}           # [2] validation subref
       , $write_protected             # [3] bool
       , $$scalar                     # [4] lvalue
!
                
, END_SUB => q!
   ; @_ == 2
     ? ( $$scalar = $_[1] )           # old fashioned ()
     :   $$scalar                     # lvalue assignment
   }
!
}

; sub import
   { my ($pkg, @args) = @_
   ; my $callpkg = caller
   ; foreach my $item ( @args )                  # foreach items
      { $item = { name => $item }
                unless ref $item eq 'HASH'
      ; $$item{name} = [ $$item{name} ]
                       unless ref $$item{name} eq 'ARRAY'
      ; foreach my $n ( @{$$item{name}} )        # foreach property
         {
         ###### DEFAULT ######
         ; my $default
         ; if ( defined $$item{default} )        # if default key
            { $default = $$item{default}         # set the default
            ; if ( defined $$item{validation} )  # if validation key
               { local $_ = $default             # set $_
               ; $$item{validation}( $_[0]       # check value (only if def key)
                                   , $_
                                   )
                 or croak qq(Invalid default value for "$n" property)
               ; $default = $_                   # set default
               }
            }
         ; my $is_class = $pkg =~ /^Class::props$/
         ; my $sub = START_SUB
         ; if (  $is_class
              || $$item{protected}
              )
            { $sub .= SET_CLASS
            }
         ; if ( $is_class )
            { $sub .= CLASS
            }
           else
            { $sub .= OBJECT
            }
         ; if ( defined $default )
            { $sub .= DEFAULT
            }
         ; if (  defined $$item{validation}
              || $$item{protected}
              )
            { $sub .= DECLARE_WRITE_PROTECTED
            }
         ; if ( $$item{protected} )
            { $sub .= PROTECTED
            }
         ; if (  defined $$item{validation}
              || $$item{protected}
              )
            { $sub .= TIE
            }
         ;    $sub .= END_SUB
        # ; warn "### $n ###\n$sub\n"
         ; no strict 'refs'
         ; eval '*{"$callpkg\::$n"} ='. $sub
         }
      }
   }
                
; sub TIESCALAR
   { bless \@_, shift
   }
   
; sub FETCH
   { $_[0][4]
   }

; sub STORE
   { local $_ = $_[1]
   ; if ( $_[0][3] )             # write protected
      { croak qq("$_[0][1]" is a read-only property)
      }
             
   ; if ( defined $_[0][2] )     # validation subref
      { $_[0][2]( $_[0][0]
                , $_
                )
        or croak qq(Invalid value for "$_[0][1]" property)
      }
   ; $_[0][4] = $_
   }


; 1

__END__

=head1 NAME

Base::OOTools - Base class for OOTools pragmas

=head1 VERSION 1.12

Included in OOTools 1.12 distribution. The distribution includes:

=over

=item * Class::new

Pragma to implement constructor methods

=item * Class::props

Pragma to implement lvalue accessors with options

=item * Object::props

Pragma to implement lvalue accessors with options

=back

=head1 DESCRIPTION

This is a base class for the OOTools distribution. Not to be used directly.

=head1 AUTHOR

Domizio Demichelis, <dd@4pro.net>.

=head1 COPYRIGHT

Copyright (c)2002 Domizio Demichelis. All Rights Reserved. This is free software; it may be used freely and redistributed for free providing this copyright header remains part of the software. You may not charge for the redistribution of this software. Selling this code without Domizio Demichelis' written permission is expressly forbidden.

This software may not be modified without first notifying the author (this is to enable me to track modifications). In all cases the copyright header should remain fully intact in all modifications.

This code is provided on an "As Is'' basis, without warranty, expressed or implied. The author disclaims all warranties with regard to this software, including all implied warranties of merchantability and fitness, in no event shall the author, be liable for any special, indirect or consequential damages or any damages whatsoever including but not limited to loss of use, data or profits. By using this software you agree to indemnify the author from any liability that might arise from it is use. Should this code prove defective, you assume the cost of any and all necessary repairs, servicing, correction and any other costs arising directly or indrectly from it is use.

The copyright notice must remain fully intact at all times. Use of this software or its output, constitutes acceptance of these terms.



