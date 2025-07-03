#!/usr/bin/perl -w

use strict;
use warnings;
use lib '/opt/zimbra/common/lib/perl5/x86_64-linux-thread-multi';
use DBI;
use POSIX qw(strftime);

# Configurazione MySQL
my $dsn    = "DBI:mysql:database=zimbra_stats;host=10.69.190.254;port=3306";
my $dbuser = "zimbra_stats";
my $dbpass = "zimbra_stats";
my %attr   = ( PrintError => 0, RaiseError => 1 );
my $dbh    = DBI->connect( $dsn, $dbuser, $dbpass, \%attr )
  or die "Errore connessione DB: $DBI::errstr";

my $sql =
  "INSERT INTO zimbra_collect (date, domain, cos, total) ".
  "VALUES (?, ?, ?, ?) ".
  "ON DUPLICATE KEY UPDATE total = GREATEST(total, VALUES(total))";
my $stmt = $dbh->prepare($sql);

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

# Log file (sovrascritto a ogni run)
my $logfile = '/tmp/zimbra_stats.log';
open my $logfh, '>', $logfile or die "Impossibile aprire il log: $!";

sub log_msg {
    my ($msg) = @_;
    my $timestamp = strftime( "%Y-%m-%d %H:%M:%S", localtime );
    print $logfh "[$timestamp] $msg\n";
}

log_msg("Avvio script, data report: $today");

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

    # Scrittura su MySQL e log solo se total > 0
    foreach my $cos ( sort keys %counts ) {
        my $total = $counts{$cos};
        if ( $total > 0 ) {
            $stmt->execute( $today, $domain, $cos, $total )
              or die "Errore inserimento DB: $DBI::errstr";
            log_msg("Dominio: $domain - COS: $cos - Totale: $total");
        }
    }
}

$stmt->finish;
$dbh->disconnect;
log_msg("Script completato con successo.");
close $logfh;

exit 0;

