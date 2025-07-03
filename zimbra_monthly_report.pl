
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

my $sql =
  "SELECT * FROM Report WHERE thisYear = YEAR(CURRENT_DATE - INTERVAL 1 MONTH) "
  . "AND thisMonth = MONTH(CURRENT_DATE - INTERVAL 1 MONTH)";
my $stmt  = $dbh->prepare($sql);
$stmt->execute();

use HTML::Table::FromDatabase;
my $table = HTML::Table::FromDatabase->new(
  -sth => $stmt,
  -override_headers => [ 'Anno', 'Mese', 'Dominio', 'COS', 'Totale' ],
  -border            => 1,
  -padding           => 5
);

$stmt->finish();
$dbh->disconnect();

use MIME::Lite;
my $msg = MIME::Lite->new(
  Subject => 'Uso mensile di caselle Zimbra',
  Data    => $table,
  Type    => 'text/html'
);

my $smtp_server = 'SMTP_SERVER';
my $smtp_port   = 587;
my $smtp_user   = 'SMTP_USER';
my $smtp_pass   = 'SMTP_PASS';
my $smtp_auth   = 1;

use Net::SMTPS;
my $smtps = Net::SMTPS->new($smtp_server, Port => $smtp_port, doSSL => 'starttls', Debug => 0)
  or die "Connessione SMTP fallita";

if ($smtp_auth) {
    $smtps->auth($smtp_user, $smtp_pass) or die("Autenticazione SMTP fallita");
}

$smtps->mail('mittente@example.com');
$smtps->to('destinatario1@example.com', 'destinatario2@example.com');
$smtps->data();
$smtps->datasend( $msg->as_string() );
$smtps->dataend();
$smtps->quit;

exit 0;
