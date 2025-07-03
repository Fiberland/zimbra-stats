#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX qw(strftime);
use MIME::Lite;
use Net::SMTPS;

# Percorso CSV da inviare
my $csv_file = '/percorso/del/file/zimbra_report.csv';

# Componi email
my $msg = MIME::Lite->new(
    From    => 'mittente@example.com',
    To      => 'destinatario1@example.com, destinatario2@example.com',
    Subject => 'Report giornaliero Zimbra',
    Type    => 'multipart/mixed'
);

# Corpo dell'email
$msg->attach(
    Type => 'TEXT',
    Data => "In allegato il report giornaliero Zimbra in formato CSV."
);

# Allegato CSV
$msg->attach(
    Type        => 'text/csv',
    Path        => $csv_file,
    Filename    => 'zimbra_report.csv',
    Disposition => 'attachment'
);

# Configurazione SMTP
my $smtp_server = 'SMTP_SERVER';
my $smtp_port   = 587;
my $smtp_user   = 'SMTP_USER';
my $smtp_pass   = 'SMTP_PASS';
my $smtp_auth   = 1;

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
