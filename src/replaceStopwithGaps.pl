#!/usr/bin/perl -w
#
# use this to remove stop codons from an alignment
# typically, this would be done to calculate dN/dS in HYPHY
# Usage: perl ../Scripts/ReplaceStopWithGaps.pl -pep 104D5_pep.fasta -nuc 104D5.fasta -output 104D5_nostop.fasta
# use this to replace stop codons from the nucleotide alignment
# the nucleotide and the peptide alignments are necessary 


use strict;
use Getopt::Long; 
use Bio::SeqIO;

my ($inpep,$innuc,$output, $i, %stop);
&GetOptions(
	    'pep:s'      => \$inpep,#
	    'nuc:s'      => \$innuc,
	    'output:s'   => \$output,#file without gaps
           );


my $pep = Bio::SeqIO->new(-file => "$inpep" , '-format' => 'fasta');
my $nuc  = Bio::SeqIO->new(-file => "$innuc" , '-format' => 'fasta');
my $out = Bio::SeqIO->new(-file => ">$output" , '-format' => 'fasta');

my %pep_size;

while ( my $pepseq = $pep->next_seq() ) {
      my $pep_str=uc($pepseq->seq);
      my $pep_id=$pepseq->id();
      my @aa=split(//,uc($pepseq->seq));
      my $psize=scalar(@aa);
      $pep_size{$pep_id}=$psize;
 #     print "$pep_id peptide sequence has size $pep_size{$pep_id}\n";
#	my $pause=<STDIN>;
}

#exit;

while (my $nucseq = $nuc->next_seq()){
  my $nuc_id=$nucseq->id();
  my $nuc_str=uc($nucseq->seq);
      $nuc_str=~s/-//g;
      my $nuc_size=length($nuc_str);
      my $expected_size=$nuc_size/3;
      my $sobra=$pep_size{$nuc_id}-$expected_size;
      my $Check_codons=$nuc_size%3;
#      print "$nuc_id\tNuc:$nuc_size\t$expected_size\t=?$pep_size{$nuc_id}\t$sobra\t$Check_codons\n";
#	print "pausa\n";
#	my $pause=<STDIN>;
    if ($sobra == -1){
#      foreach my $site (keys %{$stop{$pid}}){
#	print "May have stop codon\n";
		  #print "The sequence for $nuc_id is \n$nuc_str\n";
#		  my $nucpos=$site*3;
    	if ($Check_codons == 0){
		  my $last_codon =  substr $nuc_str,-3;
		if ($last_codon =~ /(((U|T)A(A|G|R))|((T|U)GA))/i){
			#print "$last_codon match a stop codon\n";
			chop $nuc_str for 1 .. 3;
			my $newsize=length($nuc_str);
			#print "$nuc_size > $newsize\n";
			}
		}
	}
     else{
	print "Sobra $sobra Doesn't seem to match a stop codon,$nuc_id should be manually checked\n";
	}
 #     }
    
  my $newseq = Bio::Seq->new(-seq => "$nuc_str",                           
                         -display_id => $nuc_id);
  $out->write_seq($newseq); 
}

