##!/osr/bin/perl 
#use strict;
#rse warnings;
use 5.010;

#use Proc::PID::File;
#use Proc::Daemon;
#say "start!";
#
#if(Proc::PID::File->running(name => "jukebox", dir => "/run/shm"))
#{
#	print "Already Running !";
#} else {
#	Proc::Daemon->Init;
#	unless (Proc::PID::File->running(name => "jukebox", dir => "/run/shm"))
#	{
#		#	system ('omxplayer /media/backup/MP3/A/beep.mp3');
#	say "Finished";
#	}
#}
#use Audio::Play::MPG123;
#  
#  my $player = new Audio::Play::MPG123;
#  $player->load("/media/backup/MP3/A/*");
#  #print $player->artist,"\n";
##  while($player->state)
##  {
##	  $player->poll(1);
##	  say $player->state;
##  }
#  $player->poll(1) until $player->state == 3;

#use Daemon::Mplayer;
#my $pidfile = "/run/shm/jukebox.pid";
#my @musics = glob "/media/backup/MP3/A/*";
#say "@musics";
#Daemon::Mplayer::mplayer_play({pidfile=>$pidfile,logfile=>"/run/shm/log", args => [@musics]});
#
#say "play start";
#open $fh, '<', $pid;
#my $pid = <$fh>;
#say $pid;
#Daemon::Mplayer::mplayer_stop($pid);
#------------------------------------------------
use Audio::Play::MPlayer;
use Term::ReadKey;
#
##ReadMode 4;
#
#
#
#$player = Audio::Play::MPlayer->new;
#say $player->state;
#$player->load( "/Users/operator1732/Downloads/mp3/frozen/go.mp3" ) unless $player->state;
#$player->poll(0);
#$player->stop;
#
#
#$player->poll(0) until $player->state == 0;

#while (1)
#{
#
#
#	my $key = Term::ReadKey::ReadKey(-1);
#	$player->poll( 1 ) if $player->state;
#	if(defined $key){
#	
#		if($key eq 'p')
#		{
#			say "play";
#			printf "state %d", $player->state;
#			$player->load( "/media/backup/MP3/A/message.mp3" ) unless $player->state;
#		}
#		elsif( $key eq 's')
#		{
#			printf "state %d", $player->state;
#			say "stop!";
#			$player->stop; 
#			say "stopped!";
#		}
#		elsif( $key eq 'j')
#		{
#			printf "state %d", $player->state;
#			say "jump!";
#			$player->jump(10) if $player->state ;
#			say "jumpped!";
#		}
#		
#	}
#}
##
#ReadMode 0;
#
#
#
  use Config::Simple;

  # --- Simple usage. Loads the config. file into a hash:
  Config::Simple->import_from('app.ini', \%Config);


  # --- OO interface:
  $cfg = new Config::Simple('app.ini');

#  # accessing values:
  $user = $cfg->param('mysql.password');
  say $user;
#
#  # getting the values as a hash:
#  %Config = $cfg->vars();
#  foreach (keys %Config) {
#	  say $Config{$_};
#  }
#
#  # updating value with a string
  say $cfg->param('mysql.user', "asdfx");
#
#  # updating a value with an array:
#  $cfg->param('Users', ['sherzodR', 'geek', 'merlyn']);
#
#  # adding a new block to an ini-file:
#  $cfg->param(-block=>'last-access', -values=>{'time'=>time()});
#
#  # accessing a block of an ini-file;
#  $mysql = $cfg->param(-block=>'mysql');
#
#  # saving the changes back to file:
#  $cfg->save();
#
#
#  # --- tie() interface
#  tie %Config, "Config::Simple", 'app.ini';
