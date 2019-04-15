package Text::CSV::FromAOH;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(csv_from_aoh);

sub csv_from_aoh {
    require Text::CSV_XS;

    my ($aoh, %opts) = @_;

    # determine field indexes
    my %field_idxs = %{ $opts{field_idxs} // {} };
    my %used_idxs; for (keys %field_idxs) { $used_idxs{ $field_idxs{$_} }++ }

    for my $h (@$aoh) {
        for my $k (keys %$h) {
            next if exists $field_idxs{$k};
            my $i = 0;
            while (1) {
                unless ($used_idxs{$i}) {
                    $field_idxs{$k} = $i;
                    $used_idxs{$i}++;
                    last;
                }
                $i++;
            }
        }
    }

    # generate CSV
    my $aoa = [];
    my $header = [];
    for (keys %field_idxs) { $header->[ $field_idxs{$_} ] = $_ }
    push @$aoa, $header;
    for my $h (@$aoh) {
        my $ary = [];
        for my $k (keys %$h) { $ary->[ $field_idxs{$k} ] = $h->{$k} }
        push @$aoa, $ary;
    }
    my $res;
    Text::CSV_XS::csv(in => $aoa, out => \$res);
    $res;
}

1;
#ABSTRACT: Convert an AoH (array of hashes) to CSV

=for Pod::Coverage ^(max)$

=head1 SYNOPSIS

 use Text::CSV::FromAOH qw(csv_from_aoh);

 print csv_from_aoh(
     [ {foo=>1}, {bar=>1}, {baz=>1}, {foo=>2,bar=>2}, {bar=>3,baz=>3} ],
     # field_idxs => {foo=>0}, # optional: by default fields are ordered by occurrence
 );

will print something like:

 foo,bar,baz
 1,"",""
 "",1,""
 "","",1
 2,2,""
 "",3,3


=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 csv_from_aoh

Usage:

 csv_from_aoh( \@aoh [, %opts ] ) => str


=head1 SEE ALSO

L<Text::CSV_XS>

=cut
