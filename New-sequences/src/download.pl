#!/usr/bin/perl

###############################################################
############   Declare Functions  ############################
###############################################################
use LWP::Simple;

my %ORGS;
sub ReadFile;
sub ReadID;
sub DownloadGenome;
my $file=$ARGV[0];## RAST user

# NCBI.pl usuario passowrd 
###############################################################
############		Main     ##############################
%ORGS=ReadFile($file);
foreach my $ID (keys %ORGS){
	#print ("$id => $ORGS{$id}\n")
	$OrgName=$ORGS{$ID};
	my $Flag=DownloadGenome($ID, $OrgName);
#	UploadGenome($ID, $OrgName,$Flag,$user,$pass);

}
#ReadID;

###############################################################
###############################################################

sub ReadFile{
	my $file=shift;
	open FILE,  "$file" or die "I can not open the input FILE\n";
	my %orgs;
	while (my $line=<FILE>){
		chomp $line;
		#print "$line\n";
		my @content= split(/\t/,$line);
		#print"$content[0] => $content[1]\n";	
		$orgs{$content[0]}=$content[1]." ".$content[0];
		#print"$content[0]=>$ORGS{$content[0]}\n\n";
		}
	return %orgs;
}
###############################################################

###############################################################
## 0 Reading the ID
sub ReadID{
	my $ID=shift;
	my $Flag="";

	#my $ID="ACGD01";
	#my $ORGNAME="Corynebacterium Accolens Atcc 49725 $ID";
	#my $ID="NZ_JODT01";
	#my $ORGNAME="Streptomyces Achromogenes Subsp. Achromogenes $ID";

	if ($ID=~/^[0-9]+$/){	#only match numbers then is Gi
		#print ("$ID is GI\n");	
		$Flag="GI";
		}
	elsif($ID=~/_/){	#match _ then is nucleotide
		#print ("$ID is nucleotide ID\n");		
		$Flag="NU";
		}
	elsif(substr($ID,0,4)=~/^[A-Za-z]{4}$/ and substr($ID,-2)=~/^[0-9]+$/){	# first 4 letters, last 2 numbers then is genome
		print("$ID is genome ID\n");
		$Flag="GE";
	}
	elsif($ID=~/CP/){
		$Flag="CP";
		}
	else {
		print("Please Provide a valid ID. $ID is not valid\n");
		}
	return($Flag);
}

#################################################################
##1	Download Genome from NCBI using Unique Genome identifier
sub DownloadGenome{
	my $ID=shift;
	my $Flag=ReadID($ID);
	print ("$ID,$Flag\n");
	my $ORGNAME=shift;
	my $file=$ID.".genome";

	##(Identifiers previously collected by lab members)
	if ($Flag eq "GE"){
		##1.1.1	If Genome Id (Use of wget)
		my $first=substr($ID,0,2);
		my $second=substr($ID,2,2);

#		`wget http://www.ncbi.nlm.nih.gov/Traces/wgs/?download=$ID.1.fsa_nt.gz`;
		print "wget ftp://ftp.ncbi.nlm.nih.gov/sra/wgs_aux/$first/$second/$ID/$ID.1.fsa_nt.gz\n";
		`wget ftp://ftp.ncbi.nlm.nih.gov/sra/wgs_aux/$first/$second/$ID/$ID.1.fsa_nt.gz`;
		##1.2 Decompress the file
#			print "Enter to continue\n";
#		my $pause=<STDIN>;	
		print "Done $ID \n\n";	
		`gunzip $ID.1.fsa_nt.gz`;
		`mv $ID.1.fsa_nt $file`;
		}
	elsif($Flag eq "NU"){
		##1.1.2 	If Nucleotide Id (Use of Entrez)
		$base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
		$url = $base . "efetch.fcgi?db=Nucleotide&id=$ID&rettype=gb";
		print "url $url\n";
#		my $pause=<STDIN>;
		$output = get($url);
		#$output = "hello";
		open(GENOME,'>',$file) or die "Could not open file $!";
		print GENOME ($output);
		close GENOME;
		}
	elsif($Flag="CP"){	
		##1.1.2 	If Nucleotide Id (Use of Entrez)
		print "Downloading ... \nefetch.fcgi?db=nuccore&id=$ID&rettype=gbwithparts\n";
		$base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
		$url = $base . "efetch.fcgi?db=nuccore&id=$ID&rettype=gb";
		$output = get($url);
		#$output = "hello";
		open(GENOME,'>',$file) or die "Could not open file $!";
		print GENOME ($output);
		close GENOME;
		}
	elsif($Flag eq "GI"){
		##1.1.2 	If GI Id (Use of Entrez)
		}
	return $Flag;
}

