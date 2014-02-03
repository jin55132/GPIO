#!/usr/bin/perl 

use 5.010;
use File::Spec::Functions qw (catfile);
use File::Glob qw( bsd_glob );
#use Audio::Play::MPlayer;
use Audio::Play::MPG123;
use Term::ReadKey;
use Time::HiRes qw ( time alarm sleep );
use File::Find;

#use Device::BCM2835;


#Device::BCM2835::set_debug(1);
#Device::BCM2835::init() or die "init die";
#Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_12,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
#Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_13,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
#Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_15,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;

my $isPlaying = 0;
my $isTimeToNextSong;
my @music_dirs = &getMusicDirectories('/media/backup/MP3'); 
#my @music_dirs = &getMusicDirectories('~/Downloads/mp3'); 
my @current_dirs;
my @musics;
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
		   if ($isPlaying){
			   say "Try Stop";
			   @musics = undef;
				}
		   else{
			   say "Play";
			   	@current_dirs = @music_dirs;
#				@musics = &getMusicToPlay(shift @current_dirs);
				@musics = &getNextAlbum;
		   }
			$isTimeToNextSong = 1;
		   #Device::BCM2835::delay(500); # Milliseconds
	   }
#	   elsif (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_13))
	   elsif ($key eq 'N')
	   {
		   if ($isPlaying){
				@musics = &getNextAlbum;
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
			$isTimeToNextSong = 1;
	   		say "#next song";

		   }
#			Device::BCM2835::delay(500); # Milliseconds
	   }


   sleep(0.5);

	}
	
	   $player->poll(0);
	   if(defined ($player->state)){
		   if($player->state == 3 and $isPlaying)
		   {
			   $isTimeToNextSong = 1;
			   $isPlaying = 0;
		   } else {
		   }
	   }

	   if( defined($isTimeToNextSong) )
	   {
		   say "Time to Next Song";
		   my $songToPlay = shift @musics;

	   		if ($isPlaying){
				$player->poll(0);
				$player->stop;
		  		say "Stop"; 
				$isPlaying = 0;
			}

		   if(defined($songToPlay)){
			$isPlaying = 1;	
			$player->load($songToPlay);
			say "play : ". $songToPlay;
		   } else {
			   say "$current_dirs[0]";
			   say "no song in directory";
		   }
			$isTimeToNextSong = undef;
	   }
}

#ReadMode 0; # Reset tty mode before exiting
sub getNextAlbum {

	my @songs;
	until (@songs){
	    my $dir = shift @current_dirs;
	 	@songs = &getMusicToPlay( $dir );
	 }
	 return @songs;
}

sub nextSong {
	

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



