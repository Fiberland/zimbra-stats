#!/usr/bin/perl -w

use strict;
use warnings;
use lib '/opt/zimbra/common/lib/perl5/x86_64-linux-thread-multi';
use POSIX qw(strftime);

# Report CSV compatibile con invio email
my $csv_file = '/tmp/zimbra_usage_report.csv';
my $log_file = '/tmp/zimbra_usage_report.log';

# Apertura file CSV
open my $fh, '>', $csv_file or die "Impossibile creare il file CSV: $!";

# Apertura file di log
open my $logfh, '>', $log_file or die "Impossibile creare il file di log: $!";

sub log_msg {
    my ($msg) = @_;
    my $timestamp = strftime( "%Y-%m-%d %H:%M:%S", localtime );
    print $logfh "[$timestamp] $msg\n";
}

# Intestazione CSV
print $fh "Data,Dominio,COS,Totale\n";

# Attributi classificazione ZURT
my @pe_attrs  = qw(
  zimbraFeatureMAPIConnectorEnabled
  zimbraFeatureMobileSyncEnabled
  zimbraArchiveEnabled
);
my @se_attrs = qw(
  zimbraFeatureConversationsEnabled
  zimbraFeatureTaggingEnabled
  zimbraAttachmentsIndexingEnabled
  zimbraFeatureViewInHtmlEnabled
  zimbraFeatureGroupCalendarEnabled
  zimbraFreebusyExchangeURL
  zimbraFeatureSharingEnabled
  zimbraFeatureTasksEnabled
  zimbraFeatureBriefcasesEnabled
  zimbraFeatureSMIMEEnabled
  zimbraFeatureVoiceEnabled
);
my @bep_attrs = qw(
  zimbraFeatureManageZimlets
  zimbraFeatureCalendarEnabled
);

# Data corrente
my $today = strftime( "%Y-%m-%d", localtime );
log_msg("Avvio generazione CSV, data report: $today");

# Inizio scansione domini
my @domains = `su - zimbra -c 'zmprov gad'`;
chomp @domains;

foreach my $domain (@domains) {
    my %counts = ( PE => 0, SE => 0, BEP => 0, BE => 0 );

    # Lista account (escludo galsync)
    my @accounts =
      grep { $_ !~ /^galsync/i } `su - zimbra -c 'zmprov -l gaa $domain'`;
    chomp @accounts;

    log_msg("Elaborazione dominio: $domain (Utenti: " . scalar(@accounts) . ")");

    foreach my $account (@accounts) {

        # Lettura attributi a livello account
        my %attrs;
        my $cmd = "zmprov ga '$account' "
          . join( ' ', @pe_attrs, @se_attrs, @bep_attrs );
        my @output = `su - zimbra -c "$cmd"`;

        foreach my $line (@output) {
            if ( $line =~ /^(\S+):\s+(TRUE|FALSE)/i ) {
                $attrs{$1} = uc $2;
            }
        }

        # Classificazione ZURT (con check sicuro)
        my $category = 'BE';
        if ( grep { exists $attrs{$_} && $attrs{$_} eq 'TRUE' } @pe_attrs ) {
            $category = 'PE';
        }
        elsif ( grep { exists $attrs{$_} && $attrs{$_} eq 'TRUE' } @se_attrs ) {
            $category = 'SE';
        }
        elsif ( grep { exists $attrs{$_} && $attrs{$_} eq 'TRUE' } @bep_attrs ) {
            $category = 'BEP';
        }

        $counts{$category}++;
    }

    # Scrittura dati su CSV solo se total > 0
    foreach my $cos ( sort keys %counts ) {
        my $total = $counts{$cos};
        if ( $total > 0 ) {
            print $fh join( ',', $today, $domain, $cos, $total ) . "\n";
            log_msg("Dominio: $domain - COS: $cos - Totale: $total");
        }
    }
}

close $fh;
close $logfh;

print "Report CSV generato con successo in $csv_file\n";

exit 0;

