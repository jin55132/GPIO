#!/usr/bin/perl 
use strict;
use warnings;
use File::Spec::Functions qw (catfile);
use Device::BCM2835;
use File::Glob qw( bsd_glob );
use Audio::Play::MPlayer;
use 5.010;


#foreach (@sorted_dir)
#{
#	say "$_";
#}

#Device::BCM2835::set_debug(1);
Device::BCM2835::init() or die "init die";
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_12,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_13,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_15,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;

my $isPlaying;
my $isTimeToNextSong;
my @music_dirs = &getMusicDirectories('/media/backup/MP3'); 
my @current_dirs;
my $next_song;
my @musics;
my $pid;
my $player = Audio::Play::MPlayer->new;


while(1)
{
   if (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_12))
   {
	   if ($player->state){
		   say "Stop";
		   $next_song = undef;
			&kill_process;
		}
	   else{
		   say "Play";
		   	@current_dirs = @music_dirs;
			@musics = &getMusicToPlay(@current_dirs);
			$isTimeToNextSong = 1;
	   }
		Device::BCM2835::delay(500); # Milliseconds
   }
   elsif (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_13))
   {
	   if ($player->state){
	   		say "#next album";
			&kill_process;
			shift @current_dirs;
			@musics = &getMusicToPlay(@current_dirs);
			$isTimeToNextSong = 1;
	   }
		Device::BCM2835::delay(500); # Milliseconds
   }
   elsif (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_15))
   {
	   #next song
	   if ($player->state){
   		say "#next song";
			&kill_process;
			$isTimeToNextSong = 1;
	   }
		Device::BCM2835::delay(500); # Milliseconds
   }

	   $player->poll(0);
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
        &fork_process($songToPlay);
		$isTimeToNextSong = undef;
	   }
   }
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
	my @songs = bsd_glob("$dir_to_play/*");
}

sub kill_process {
#	system ('kill $(ps aux | grep \'[o]mxplayer\' | awk \'{print $2}\')') unless defined $isTimeToNextSong;
#	say "try to kill $pid";
#	kill INT => $pid or say "failed to kill" ;
	$player->stop;
}


sub fork_process {
	my $song = shift @_;

	$player->load($song);
	
#	$SIG{CHLD} = 'IGNORE';
#	defined ($pid = fork) or die "cannot fork $!";
#
#	unless($pid)
#	{
#		close STDIN;
#		close STDOUT;
#		foreach (@_) {
#			system ("omxplayer $_"); 
#		}
#		exit(0);
#	}
}
