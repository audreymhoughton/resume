use POSIX qw(strftime);

my $base = 'AudreyHoughton';
my $date = strftime('%m%d%Y', localtime);

$jobname = "${base}_${date}";

END {
  my $current = "${jobname}.pdf";
  return unless -e $current;

  # Remove old dated PDF files
  for my $pdf (glob("${base}_*.pdf")) {
    next if $pdf eq $current;
    unlink $pdf;
  }

  # Remove old dated auxiliary files
  for my $ext (qw(aux fdb_latexmk fls log out)) {
    for my $file (glob("${base}_*.${ext}")) {
      my $current_aux = "${jobname}.${ext}";
      next if $file eq $current_aux;
      unlink $file;
    }
  }
}
