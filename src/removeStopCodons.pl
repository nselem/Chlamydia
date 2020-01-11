#!/usr/bin/perl -w
#
# use this to remove stop codons from an alignment
# typically, this would be done to calculate dN/dS in HYPHY
# Usage: perl ../Scripts/ReplaceStopWithGaps.pl -pep 104D5_pep.fasta -nuc 104D5.fasta -output 104D5_nostop.fasta -ref 104D5S1
# use this to replace stop codons from the nucleotide alignment with the codon of the reference
# the nucleotide and the peptide alignments are necessary and the name of the reference sequence
# the reference sequence needs to be in the nucleotide alignment
 
 
use strict;
use Getopt::Long; 
use Bio::SeqIO;
 
my ($inpep,$innuc,$output, $i, %stop,$ref,$refseq,@sequences);
&GetOptions(
      'pep:s'      => \$inpep,#
	    'nuc:s'      => \$innuc,
	    'output:s'   => \$output,#file without gaps
	    'ref:s'      => \$ref,#the name of codon sequence to use as reference
           );

print "Parameters\nref = $ref\n"; 
print "Nucleotide Alignment  = $innuc\n"; 
print "Aminoacid alignment  = $inpep\n"; 
 
my $pep = Bio::SeqIO->new(-file => "$inpep" , '-format' => 'fasta');
my $nuc  = Bio::SeqIO->new(-file => "$innuc" , '-format' => 'fasta');
my $out = Bio::SeqIO->new(-file => ">$output" , '-format' => 'fasta');
 
while ( my $pepseq = $pep->next_seq() ) {
    my $pep_str=uc($pepseq->seq);
    if ($pep_str=~/\*/){
      my $pep_id=$pepseq->id();
      my @aa=split(//,uc($pepseq->seq));
      for ($i=0; $i<scalar(@aa); $i++){
        if ($aa[$i]=~/\*/){
      		$stop{$pep_id}=$i;
      		print "$pep_id peptide sequence has a stop $aa[$i] at ".($stop{$pep_id}+1)."\n";
      	}
      }
    }
}


#	exit;  
while (my $nucseq = $nuc->next_seq()){
  my $nuc_id=$nucseq->id();
	print "$nuc_id\n";
if ($nuc_id=~/$ref/){
    $refseq=lc($nucseq->seq());
	print "Es referencia $ref\n";
  }
  push(@sequences,$nucseq);
}
print "The reference sequence $ref is:\n$refseq\n";

foreach my $nucseq (@sequences){
  my $nuc_id=$nucseq->id();
  my $nuc_str=uc($nucseq->seq);
  foreach my $pid (keys %stop){
 
    if ("$nuc_id" eq "$pid"){
      #print "match $nuc_id and $pid\n";
      #print "The sequence for $nuc_id is \n$nuc_str\n";
      my $nucpos=$stop{$pid}*3;
      my $codon =  substr $nuc_str, $nucpos, 3;
      print "$codon ";
      if ($codon =~ /(((U|T)A(A|G|R))|((T|U)GA))/){
        my $refcodon = substr($refseq, $nucpos, 3);
        print "reference codon is $refcodon\n";
        substr($nuc_str, $nucpos, 3) = substr($refseq, $nucpos, 3);
        print "=> Match to a stop codon at nucleotide position ".($nucpos+1)."\nNew sequence for $nuc_id\n$nuc_str\n";
      }else{
        print "Doesn't seem to match a stop codon at nucleotide position ".($nucpos+1)." in $nuc_id\n";
      }
      
    }
  }
  my $newseq = Bio::Seq->new(-seq => "$nuc_str",                           
                         -display_id => $nuc_id);
  $out->write_seq($newseq); 
}
