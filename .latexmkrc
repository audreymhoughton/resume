use POSIX qw(strftime);

my $base = 'AudreyHoughton';
my $date = strftime('%m%d%Y', localtime);

$jobname = "${base}_${date}";

END {
  my $current = "${jobname}.pdf";
  return unless -e $current;

  for my $pdf (glob("${base}_*.pdf")) {
    next if $pdf eq $current;
    unlink $pdf;
  }
}
