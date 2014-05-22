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
use Device::BCM2835 ;
use Cwd;
use Proc::PID::File;
use Proc::Daemon;
use Config::Simple;
use strict;


#Device::BCM2835::set_debug(1);

my $isPlaying = 0;
my $isTimeToNextSong= 0;
my @music_dirs;
#my @music_dirs = &getMusicDirectories('~/Downloads/mp3'); 
my @current_dirs;
my @current_songs;
my $cfg;
my $pwd = getcwd;
#my $player = Audio::Play::MPlayer->new;
	
if (Proc::PID::File->running(name => "jukebox", dir => "/var/run"))
{ 
		print "Already running!";
} 
else 
{
	print "Start jukebox\n";
    my $daemon = Proc::Daemon->new( work_dir => $pwd, child_STDOUT => '/var/log/out', child_STDERR => '/var/log/err');
	print "init\n";
    $daemon->Proc::Daemon::Init;
	
	print "Start Daemon";

	unless (Proc::PID::File->running(name => "jukebox", dir => "/var/run"))
	{
		say "start main func";
			&main;
	}

	say "Failed to start";
}

sub main {
			 
	#ReadMode 4; # Turn off controls keys
	
Device::BCM2835::init() or die "init die";
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_12,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_13,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_15,&Device::BCM2835::BCM2835_GPIO_FSEL_INPT) ;

	$cfg = new Config::Simple('/etc/music.ini');
	my %config = $cfg->vars();
	say $config{"default.directory"};


	my $player = Audio::Play::MPG123->new;
	@music_dirs = &getMusicDirectories($config{"default.directory"});
	
	while(1)
	{
		my $key = Term::ReadKey::ReadKey(-1);
		$key = 0 unless(defined $key);
			 
		   if (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_12) or $key eq 'p')
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
		   }
		   elsif (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_13) or $key eq 'N')
		   {
			   if ($isPlaying){
					@current_songs = &getNextAlbum;
			   		say "#next album";
					$isTimeToNextSong = 1;
			   }
		   }
		   elsif (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_15) or $key eq 'n')
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
	
	   sleep(0.2);
		
		   $player->poll(0);
		   if(defined ($player->state)){
			   if($player->state == 3 and $isPlaying)
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
	
				$player->statfreq(0.2/$player->tpf);
	
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
	return sort @songs;
}
