#!/usr/bin/perl 

use 5.010;
use File::Spec::Functions qw (catfile);
use File::Glob qw( bsd_glob );
use Audio::Play::MPlayer;
use Term::ReadKey;
use Time::HiRes qw ( time alarm sleep );

#use Device::BCM2835;


#Device::BCM2835::set_debug(1);
#Device::BCM2835::init() or die "init die";
#Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_12,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
#Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_13,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
#Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_15,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;

my $isPlaying;
my $isTimeToNextSong;
#my @music_dirs = &getMusicDirectories('/media/backup/MP3'); 
my @music_dirs = &getMusicDirectories('~/Downloads/mp3'); 
my @current_dirs;
my $next_song;
my @musics;
my $pid;
my $player = Audio::Play::MPlayer->new;

ReadMode 4; # Turn off controls keys

while(1)
{
	my $key = Term::ReadKey::ReadKey(-1);
	if(defined $key){
#	   if (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_12))
	   if ($key eq 'p')
	   {
		   if ($player->state){
			   $player->poll(0);
			   say "Stop";
			   $next_song = undef;
				$player->stop;
				say "stopped";
			}
		   else{
			   say "Play";
			   	@current_dirs = @music_dirs;
				@musics = &getMusicToPlay(@current_dirs);
				$isTimeToNextSong = 1;
		   }
		   #Device::BCM2835::delay(500); # Milliseconds
	   }
#	   elsif (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_13))
	   elsif ($key eq 'N')
	   {
		   if ($player->state){
		   		say "#next album";
				$player->stop;
				shift @current_dirs;
				@musics = &getMusicToPlay(@current_dirs);
				$isTimeToNextSong = 1;
		   }
#			Device::BCM2835::delay(500); # Milliseconds
	   }
#	   elsif (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_15))
	   elsif ($key eq 'n')
	   {
		   #next song
		   say "state";
		   if ($player->state){
	   		say "#next song";
			$player->stop;
			say "stoppppp";
				$isTimeToNextSong = 1;
		   }
#			Device::BCM2835::delay(500); # Milliseconds
	   }


	   sleep(0.5);

	}

	   if($player->state)
	   {
	   } else {

		   $isTimeToNextSong = 1;
	   }
	
	   if( defined($isTimeToNextSong) )
	   {
		   my $songToPlay = shift @musics;
		   
		   if(defined($songToPlay)){
			say "songs : ". $songToPlay;
	
			$player->load($songToPlay);
		
			$isTimeToNextSong = undef;
		   }
	   }

	   $player->poll(0);

}
ReadMode 0; # Reset tty mode before exiting
	

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
	my @songs = bsd_glob("$dir_to_play/*");
}



