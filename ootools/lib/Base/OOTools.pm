package Base::OOTools ;
$VERSION = 1.2 ;

; use 5.006_001
; use strict
; use Carp

; use constant

{ START_SUB => q!
  sub : lvalue
   { croak qq(Too many arguments for "$n" property)
           if @_ > 2
!
, CLASS => q!
   ; my $class = ref $_[0] || $_[0]
   ; my $scalar = \${"$class\::$n"}
!
, OBJECT => q!
   ; croak qq(Wrong value type passed to "$n" object property)
           unless ref $_[0]
   ; my $scalar = \$_[0]{$n}
!
, TIE => q!
   ; unless ( tied $$scalar )
      { tie $$scalar
          , $pkg
          , $_[0]
          , $n
          , $scalar
          , $$item{default}
          , $$item{rt_default}
          , $$item{protected}
          , $$item{validation}
      }
!
, END_SUB => q!
   ; @_ == 2
     ? ( $$scalar = $_[1] )
     :   $$scalar
   }
!
}

; sub import
   { my ($pkg, @args) = @_
   ; my $callpkg = caller
   ; foreach my $item ( @args )                 # foreach items
      {      ; $item = { name => $item }
                unless ref $item eq 'HASH'
      ; $$item{name} = [ $$item{name} ]
                       unless ref $$item{name} eq 'ARRAY'
      ;  $$item{default}
      && $$item{rt_default}
      && croak qq("default" and "rt_default" options are incompatible)
      ; foreach my $n ( @{$$item{name}} )       # foreach property
         {
         ###### SUB ######
         ; my $sub  = START_SUB
         ;    $sub .= $pkg =~ /^Class::props$/
                      ? CLASS
                      : OBJECT
         ;    $sub .= TIE if defined $$item{validation}
                          or defined $$item{default}
                          or defined $$item{rt_default}
                          or defined $$item{protected}
         ;    $sub .= END_SUB
         ###### ENDSUB ######
         ; no strict 'refs'
         ; eval '*{"$callpkg\::$n"} ='. $sub
         ; print "### $n ###$sub\n" if our $print_codes
         }
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
   { my $from_FETCH = (caller(1))[3] =~ /::FETCH$/
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
   
; 1

__END__

=head1 NAME

Base::OOTools - Base class for OOTools pragmas

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

=head1 DESCRIPTION

This is a base class for the OOTools distribution. Not to be used directly.

=head1 AUTHOR

Domizio Demichelis, <dd@4pro.net>.

=head1 COPYRIGHT

Copyright (c)2002 Domizio Demichelis. All Rights Reserved. This is free software; it may be used freely and redistributed for free providing this copyright header remains part of the software. You may not charge for the redistribution of this software. Selling this code without Domizio Demichelis' written permission is expressly forbidden.

This software may not be modified without first notifying the author (this is to enable me to track modifications). In all cases the copyright header should remain fully intact in all modifications.

This code is provided on an "As Is'' basis, without warranty, expressed or implied. The author disclaims all warranties with regard to this software, including all implied warranties of merchantability and fitness, in no event shall the author, be liable for any special, indirect or consequential damages or any damages whatsoever including but not limited to loss of use, data or profits. By using this software you agree to indemnify the author from any liability that might arise from it is use. Should this code prove defective, you assume the cost of any and all necessary repairs, servicing, correction and any other costs arising directly or indrectly from it is use.

The copyright notice must remain fully intact at all times. Use of this software or its output, constitutes acceptance of these terms.



