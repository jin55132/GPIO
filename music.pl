#!/usr/bin/perl 
use strict;
use warnings;
use File::Spec::Functions qw (catfile);
use Device::BCM2835;
use File::Glob qw( bsd_glob );
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
while(1)
{
   if (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_12))
   {
	   if (defined($isPlaying)){
		   say "Stop";
		   $next_song = undef;
			$isPlaying = undef;
			&kill_process;
		}
	   else{
		   say "Play";
		   @current_dirs = @music_dirs;
			$isPlaying = 1;
			@musics = &getMusicToPlay(@current_dirs);
			$isTimeToNextSong = 1;
	   }
		Device::BCM2835::delay(500); # Milliseconds
   }
   elsif (1 == Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_V2_GPIO_P1_13))
   {
	   if (defined($isPlaying)){
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
	   if (defined($isPlaying)){
	   		say "#next song";
			&kill_process;
			$isTimeToNextSong = 1;
	   }
		Device::BCM2835::delay(500); # Milliseconds
   }

   if( defined($isTimeToNextSong) )
   {
	   my $song = shift @musics;
	   if(defined $song){
	
		say "song number:". scalar @musics . $song;
        &fork_process($song);
	   }
		$isTimeToNextSong = undef;
   }
}

sub fetchNextSong {
	

}

sub whenSongFinished {
	$isTimeToNextSong = 1;
	say "song finished";
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
#	my $play_to_song = shift @songs;
}

sub kill_process {
	$SIG{CHLD} = 'IGNORE';
	system ('kill $(ps aux | grep \'[o]mxplayer\' | awk \'{print $2}\')') unless defined $isTimeToNextSong;
}

sub fork_process {
	my $param = shift;
	

	$SIG{CHLD} = 'whenSongFinished'; 
	defined (my $pid = fork) or die "cannot fork $!";

	unless($pid)
	{
		say "Start!";
		close STDIN;
		close STDOUT;
		exec ('omxplayer', $param); 
	}

}
