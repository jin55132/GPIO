#!/usr/bin/perl 

use 5.010;
use File::Spec::Functions qw (catfile);
use File::Glob qw( bsd_glob );
#use Audio::Play::MPlayer;
use Audio::Play::MPG123;
use Term::ReadKey;
use Time::HiRes qw ( time alarm sleep );
use File::Find;
use List::Util;
use strict;
#use Device::BCM2835;


#Device::BCM2835::set_debug(1);
#Device::BCM2835::init() or die "init die";
#Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_12,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
#Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_13,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
#Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_15,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;

my $isPlaying = 0;
my $isTimeToNextSong= 0;
#my @music_dirs = &getMusicDirectories('/media/backup/MP3'); 
my @music_dirs = &getMusicDirectories('~/Downloads/mp3'); 
my @current_dirs;
my @current_songs;
#my $player = Audio::Play::MPlayer->new;
my $player = Audio::Play::MPG123->new;

#ReadMode 4; # Turn off controls keys

while(1)
{
	my $key = Term::ReadKey::ReadKey(-1);
	if(defined $key){
#	   if (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_12))
	   if ($key eq 'p')
	   {
			$isTimeToNextSong = 1;
		   if ($isPlaying){
			   say "Try Stop";
			   @current_songs = undef;
			   @current_dirs = undef;
			}
		   else{
			   say "Play";
			   	@current_dirs = @music_dirs;
				@current_dirs = List::Util::shuffle @current_dirs;
				@current_songs = &getNextAlbum;
		   }
		   #Device::BCM2835::delay(500); # Milliseconds
	   }
#	   elsif (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_13))
	   elsif ($key eq 'N')
	   {
		   if ($isPlaying){
				@current_songs = &getNextAlbum;
		   		say "#next album";
				$isTimeToNextSong = 1;
		   }
#			Device::BCM2835::delay(500); # Milliseconds
	   }
#	   elsif (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_15))
	   elsif ($key eq 'n')
	   {
		   #next song
		   if ($isPlaying){
				unless(@current_songs) {
					@current_songs = &getNextAlbum;
				}
			$isTimeToNextSong = 1;
	   		say "#next song";

		   }
#			Device::BCM2835::delay(500); # Milliseconds
	   }

   sleep(0.5);

	}
	
	   $player->poll(0);
	   if(defined ($player->state)){
		   if($player->state == 0 and $isPlaying)
		   {
			   $isTimeToNextSong = 1;
			   $isPlaying = 0;
		   } else {

		   }
	   }

	   if($isTimeToNextSong )
	   {
		   say "Time to Next Song";
		   my $songToPlay = shift @current_songs;

	   		if ($isPlaying){
				$player->poll(0);
				$player->stop;
		  		say "Stop"; 
				$isPlaying = 0;
			}

		   if(defined($songToPlay)){
			$isPlaying = 1;	
			$isTimeToNextSong = 0;
			$player->load($songToPlay);
			say "play : ". $songToPlay;
		   } else {
				@current_songs = &getNextAlbum;
				unless(@current_songs) {
					$isTimeToNextSong = 0;	
					$isPlaying = 0;
					say "finish!!!";
				}
		   }
	   }
}

#ReadMode 0; # Reset tty mode before exiting
sub getNextAlbum {
	my @songs;
	until (@songs){
	    my $dir = shift @current_dirs;
		
		return () unless defined $dir;

	 	@songs = &getMusicToPlay( $dir );
	 }
	 return @songs;
}


sub getMusicDirectories {
	my $music_dirs = shift @_;
	my @element = bsd_glob("$music_dirs/*");
	@element = grep {-d and !( $_ =~ /^\./ ) } @element;
	my @sorted_dirs = sort { (stat $b)[9] <=> (stat $a)[9]} @element;
	return @sorted_dirs;
}

sub getMusicToPlay {
	my $dir_to_play = shift @_;


	my $dir = $dir_to_play;
	$dir_to_play =~ s/\[/\\\[/g;
	$dir_to_play =~ s/\]/\\\]/g;

	my @dirs = ($dir_to_play);
#	my @songs = bsd_glob("$dir_to_play/*.mp3");
	my @songs;
	find sub { push @songs, $File::Find::name if !-d && /\.mp3$/i }, @dirs;
	return @songs;
}



