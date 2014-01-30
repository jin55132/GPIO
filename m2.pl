#!/usr/bin/perl 
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

use Audio::Play::MPlayer;

    # same as Audio::Play::MPG123
    $player = Audio::Play::MPlayer->new;
	print "play";
#    $player->load( "/media/backup/MP3/A/01.m4a" );
	$player->statfreq(0.5);
    $player->load( "/media/backup/MP3/A/timber.mp3" );
    print $player->title, "\n";

#	$player->stop;
	while ($player->state) {
		say $player->state;
		$player->poll(1);
	}

#    $player->poll( 1 ) until $player->state == 0;
	




