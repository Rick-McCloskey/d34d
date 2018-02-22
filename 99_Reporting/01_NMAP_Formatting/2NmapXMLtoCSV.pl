#!/usr/bin/perl

# Author: Travis Lee
# Date Modified: 3-5-12
# Description: Script to convert a Nmap scan XML file to CSV
#
# Usage: NmapXMLtoCSV.pl <nmap xml file.xml> <output file.csv>
# Dependancies
#       nmap
#	Sed
#	perl and Nmap::Parser module (type  "cpan App::cpanminus" then "cpanm Nmap::Parser")
# 	put 2NmapXMLtoCSV.pl in /bin
#

use Nmap::Parser;
$base = new Nmap::Parser;

if (!$ARGV[0] || !$ARGV[1])
{
 print "Usage: NmapXMLtoCSV.pl <nmap xml file.xml> <output file.csv>\n\n";
 exit;
}

$base_file = $ARGV[0]; #baseline scan filename from command line
$out_file = $ARGV[1]; #output filename from command line

$base->parsefile($base_file); #load baseline scan file

open (OUTFILE, ">$out_file");

$session = $base->get_session;
#print OUTFILE $session->scan_args."  --  Scan finished on: ".$session->time_str;

print OUTFILE "IP,Hostname,MAC,OS,Port,Proto,State,Service,Version\n";

#loop through all the IPs in the current scan file
for my $ip ($base->get_ips) 
{
        #get host object for the current IP
        $ip_base = $base->get_host($ip);

 #populate arrays with tcp/udp ports
 my @tcpports = $ip_base->tcp_ports;
 my @udpports = $ip_base->udp_ports;

 print OUTFILE $ip_base->ipv4_addr.",";
 print OUTFILE $ip_base->hostname.",";
 print OUTFILE $ip_base->mac_addr.",";

 #get os object for the current IP
 my $os = $ip_base->os_sig;

 #if smb-os-discrovery script was run, use this value for os. more accurate
 if ($ip_base->hostscripts("smb-os-discovery"))
 {
  my @os_split1 = split(/\n/, $ip_base->hostscripts("smb-os-discovery"));
  my @os_split2 = split("OS: ", $os_split1[1]);
  print OUTFILE $os_split2[1].",";
 }
 else { print OUTFILE $os->name.","; } #else use what was discovered with os fingerprint

 $first = 1;

 &portout(\@tcpports, "tcp");
 &portout(\@udpports, "udp");

 print OUTFILE "\n";
        
} #end for loop

close (OUTFILE);
print "\n\nConversion complete!\n\n";

sub portout
{
 my @ports = @{$_[0]};
 my $proto = $_[1];



 for my $port (@ports)
 {
  #get service object for the given port
  if ($proto eq "tcp")
  {
   $svc = $ip_base->tcp_service($port);
  }
  elsif ($proto eq "udp")
  {
   $svc = $ip_base->udp_service($port);
  }

  if ($first == 1) { $first = 0; }
  else { 

 #print OUTFILE ",";
 print OUTFILE $ip_base->ipv4_addr.",";
 print OUTFILE $ip_base->hostname.",";
 print OUTFILE $ip_base->mac_addr.",";

 #print OUTFILE ",,,,"; 
}

  print OUTFILE $port.",";
  print OUTFILE $proto.",";

  if ($proto eq "tcp")
  {
   print OUTFILE $ip_base->tcp_port_state($port).",";
  }
  elsif ($proto eq "udp")
  {
   print OUTFILE $ip_base->udp_port_state($port).",";
  }

  print OUTFILE $svc->name.",";
  print OUTFILE $svc->product."\n";

 } #end for loop

} #end sub

