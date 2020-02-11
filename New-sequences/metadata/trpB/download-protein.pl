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
	my $file_faa=$ID.".faa";
	my $file_fna=$ID.".fna";



		##1.1.2 	If Nucleotide Id (Use of Entrez)
		$base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
		$url = $base . "efetch.fcgi?db=Protein&id=$ID&rettype=fasta_cds_na";
		print "url $url\n";
#		my $pause=<STDIN>;
		$output_fna = get($url);
		#$output = "hello";
		open(GENOME,'>',$file_fna) or die "Could not open file $!";
		print GENOME ($output_fna);
		close GENOME;

                $base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
                $url = $base . "efetch.fcgi?db=Protein&id=$ID&rettype=fasta_cds_aa";
                print "url $url\n";
#               my $pause=<STDIN>;
                $output_faa = get($url);
                #$output = "hello";
                open(GENOME,'>',$file_faa) or die "Could not open file $!";
                print GENOME ($output_faa);
                close GENOME;
return $Flag;
}

