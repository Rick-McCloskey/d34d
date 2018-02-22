#!/usr/bin/perl
#########################################
#  _   _   _   _   _   _   _   _    
# / \ / \ / \ / \ / \ / \ / \ / \  
#( P | a | s | t | e | b | i | n ) 
# \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/  
#  _   _   _   _   _   _   _  
# / \ / \ / \ / \ / \ / \ / \ 
#( S | c | r | a | p | e | r )   v4.0 
# \_/ \_/ \_/ \_/ \_/ \_/ \_/       
##                                  
#
# Written by Sw1tCh (c) 2010 - 2011
#
# This script will go to pastebin.com and 
#  Download the latest posts from the 
#  Archive and save them to a folder named
#  saved.
#
# This script is best used with a Crontab
#  entry to automatically check.  However
#  setting a check rate of less then 15 
#  Minutes will result in a banning of your
#  IP address.
#
#########
#
# V3.5 --- 
#   IT was discovered that if you are pulling
#     in the way way that this script has, you
#     will end up pulling down only scripts 
#     that say "You are downloading Too Fast"
#
#  So, in order to combat this, the downloading 
#     has been changed to proxy over a bunch of
#     web proxies
#
########
#
# V3.6
#   So, Because 3.5 took too bloody long, 
#               threading was implimented.  This, combined
#               with the proxy should make this work and be
#               safely publicly releasable 
#
########
#
# V3.7 
#       Added support for targeting Individual users
#               pastebin folders
#
#
#######
# v4.0  
#   Made Major changes to the threading process. 
#          Added some License Items as well
#       Fixed issue with Proxies not updating on failed attempts
#          and pastes being lost.  Script also will force quit after 
#          6 minutes.
#       Added Some more comments
#       Added Intro banner
######
##########################################
#
#     License:
#       Free for personal use.  Any use for research or
#       Commercial must be approved in writing with original
#       author prior to use.    
#
##########################################

use strict;
use warnings;
use LWP::Simple;
use LWP::UserAgent;
use Thread::Pool;
use constant MOTD => q{
          _,-,-.
        ,-: |.'-:|..-.          scraper.pl -  4.0
   _..-:| | `-`. \.--'
 <...--:'-|_|_|;  \
        \   /     /
         :      ,'
         |      |   Written by Sw1tCh for ReverSecurity.com
         |      |     For ongoing research with Pastebin
         |      |   ASCII art by SSt

        usage : ./scraper.pl                    [ Pulls all recent Posts      ]
        usage : ./scraper <username>            [ Pulls all of a useres posts ] 
};

chdir("./");
##########################################################################################
####  SUB ROUTINES
##########################################################################################

# Validates user imput to determine if the run is for all recent posts or for a users posts
sub checkInput
{
        if ($#ARGV == 0 )
        {
                return my $url  = 'http://pastebin.com/u/' . $ARGV[0];
        }
        else
        {
                return my $url  = 'http://pastebin.com/archive';
        }
}

# Generate List of proxies for the script to use.  A lit of proxies can be found at :
# http://www.proxy-list.org/en/index.php
sub createProxyList
{
        open (FILE, "<", "./proxy.lst");
                my @proxyList = <FILE>;
        close FILE;
        if ($#proxyList < 1) 
                { print "Proxy List is empty...Quitting.\n"; exit; }
        return @proxyList;
}

# Routine for dumping the output 
sub dumpPaste
{
        my $printPaste = $_[0];
        my $printOutPut = $_[1];
        my $path = './saved/pastebin-' . $printPaste;

        open (DUMP, ">> $path");
                print DUMP $printOutPut;
        close (DUMP); 
}

sub getPaste
{
        my $goodPull ="false";
        my $proxy = $_[0];
        
        while ($goodPull =~ "false")
        {
                my $ua = LWP::UserAgent->new(agent => q{Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; YPC 3.2.0; .NETCLR 1.1.4322)},);
                $ua->timeout(10);
                $ua->proxy(['http'] => "http://$proxy" ); 
        
                my $url = 'http://pastebin.com/download.php?i=' . $_[1];
                my $rsp = $ua->get($url);


        if ( !( $rsp->is_success ) ||  ( $rsp->content =~ m/^500 Can\x27t connect to/ ) || ( $rsp->content =~ m/^500 read/ ) || ( $rsp->content =~ m/^500 Server closed/ ) || ( $rsp->content =~ m/Access control configuration prevents your request from/ ) || ($rsp->content =~ m/Please slow down/) ) 
        {

                        if ($rsp->content =~ m/Please slow down/) {
                                print "Going to Fast.  Changing Proxies\n";
                                sleep (30);

                        }
                        else
                        {
                        my $oldProxy = $proxy;
                        my  @proxyList = createProxyList();
                                $proxy = $proxyList[rand(@proxyList)];
                                chomp($proxy);
                                chomp($oldProxy);
                                chomp($_[1]);
                print "Proxy : " . $oldProxy . " - Failed - retrying with $proxy for $_[1] \n";
                sleep(30);
                        
                        }
                        
        }
        else
        {
                $goodPull = "true";
                chomp($proxy);
                print "AQUIRED $_[1] through $proxy\n" if  $rsp->is_success;
                        dumpPaste($_[1], $rsp->content );
        }
    }

}




########################################################################################################################
############## End Subroutines 
#######################################################################################################################






########################################################################################################################
############## Main  
#######################################################################################################################
#Setup Variables 
my @proxyList = createProxyList();
my $count = 0;
my $totalDump = 0;
my $outputDump = 0;

my $url  = checkInput();
my $CUTurl = 'http://pastebin.com/download.php?';
my $results = get($url); 

if ($results =~ m/'<title>Pastebin.com'/ ) {print "User Does not exists :/ \n"; exit;}

my @brokeResults = split /\n/, $results;


#Starting Dump from Pastebin.com
print "\n--+ Starting Dump from Pastebin.com +--\n";
my $threads = 100;
print "Making Threads...\n";
my $pool = Thread::Pool->new({
                             workers => $threads,
                             do => \&getPaste,
                             });

foreach (@brokeResults){
        while (($_ =~ /\x3D\x22\x2F(.{8})\x22/g) && ( $_ =~ m/icon/ )   ) { 
                if ( $count >= $#proxyList ){ print "-+   Letting the Proxies Cool off +-\n";$count = 0; sleep (60); print " -+ Spinning Back up...   +-\n";}
        
                if ($_ =~  /\x3D\x22\x2F(.{8})\x22/ ){ 
                        my $paste = $1;
                        print "About to get : $paste Through : $proxyList[$count]";                     
                        $pool->job($proxyList[$count], $paste);
                        
                
                        $count++;
                        $totalDump++;
                        
                }       
        }
}
print "Finished Main\n   !!!! AFTER 6 MINUTES SCRIPT WILL QUIT !!!!\n";
sleep(420);
print "Total Pulled : $totalDump\n";
exit;