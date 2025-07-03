#!/usr/bin/perl -w

use strict;
use warnings;
use DBI;
use POSIX qw(strftime);

# Configurazione MySQL
my $dsn    = "DBI:mysql:database=DB_NAME;host=DB_HOST;port=3306";
my $dbuser = "DB_USER";
my $dbpass = "DB_PASS";
my %attr   = ( PrintError => 0, RaiseError => 1 );
my $dbh    = DBI->connect( $dsn, $dbuser, $dbpass, \%attr )
  or die "Errore connessione DB: $DBI::errstr";

# Esempio di inserimento (da adattare secondo il proprio CSV)
my $sql = "INSERT INTO zimbra_collect (date, domain, cos, total) VALUES (?, ?, ?, ?) "
        . "ON DUPLICATE KEY UPDATE total = GREATEST(total, VALUES(total))";
my $stmt = $dbh->prepare($sql);

# Esempio di inserimento
my $today = strftime( "%Y-%m-%d", localtime );
$stmt->execute($today, 'esempio.com', 'PE', 42)
  or die "Errore inserimento DB: $DBI::errstr";

$stmt->finish;
$dbh->disconnect;

exit 0;
