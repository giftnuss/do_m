#!perl -w
; use strict
; use Test::More tests => 7
; use IO::Util qw(slurp)

; BEGIN
   { chdir './t'
   }

; my $out = slurp 'test.txt'
; is ($$out, <<'')
test
test

; $out = slurp '0'
; is ($$out, <<'')
test
test

; eval { $out = slurp [1..3] }
; ok ($@ =~ /^Wrong/ )

;  eval { $out = slurp 'not_found' }
; ok ($@)

; open TEST, 'test.txt'
; $out = slurp *TEST
; is ($$out, <<'')
test
test

; $_ =   'test.txt'
; $out = slurp
; is ($$out, <<'')
test
test

; $out = slurp \*DATA
; is ($$out, <<'')
data
data

__DATA__
data
data
