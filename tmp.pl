#!/usr/bin/perl 
use 5.010;
#while (1) {
#    my $char = Term::ReadKey::ReadKey(-1);
##	print "%C", $char if defined ($char);
##    printf(" Decimal: %d\tHex: %x\n", ord($char), ord($char)) if defined ($char);
#	if(defined $char) {
#		say "Aye" if $char eq 'a';
#	}
#}

use Term::ReadKey;
ReadMode 4; # Turn off controls keys
   while (defined ($key = ReadKey(-1))) {
                # No key yet
        }
        print "Get key $key\n";
        ReadMode 0; # Reset tty mode before exiting
