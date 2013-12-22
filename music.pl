#!/usr/bin/perl 
use strict;
use warnings;
use File::Spec::Functions qw (catfile);
use File::Slurp qw (read_dir);
use Device::BCM2835;
use 5.010;
#my @list = File::DirList::list('.', 'M');
#
#
##Device::BCM2835::set_debug(1);
#Device::BCM2835::init() or die "init die";
#Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_12,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
#my @songs = glob "/home/operator1732/download/*.mp3";
#print "@songs";
#
#for (@songs) {
#	print "Playing $_";
#	system "mpg321 $_";
#
#}

#while(1)
#{
#    # Turn it on
#    if (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_12))
#	{
#		print "Pushed\n";
#	}
#    Device::BCM2835::delay(500); # Milliseconds
#}



my $music_dir = "/media/backup/MP3";
my @element = read_dir $music_dir;

@element = grep { -d (catfile $music_dir, $_) } @element;
@element = grep {!( $_ =~ /^\./ ) } @element;

@element = map {catfile $music_dir, $_} @element;
my @sorted_dir = sort { (stat $b)[9] <=> (stat $a)[9]} @element;
say shift @sorted_dir;

#Device::BCM2835::set_debug(1);
Device::BCM2835::init() or die "init die";
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_12,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
#
#for (@songs) {
   #   system "mpg321 $_";
   #
   #}

   #while(1)
   #{
    # Turn it on
    #    if (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_12))
    #   {
       #   }
       #    Device::BCM2835::delay(500); # Milliseconds
       #}



#foreach my $element (readdir DH) {
#	next unless -d $music_dir . '/' . $element;
#	next if $element eq '.' or $element eq '..';
#	next if $element =~ /^\./;
#
#	say $element;
#}
