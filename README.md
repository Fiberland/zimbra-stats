# Zimbra Usage Stats Toolkit

Toolkit completo per la raccolta, l'analisi e la reportistica dell'utilizzo delle caselle Zimbra.

Questo progetto fornisce script in Perl per automatizzare la generazione e l'invio di report dettagliati sull'utilizzo degli account Zimbra, ideali per ambienti multi-dominio e provider di servizi.

## Contenuto del Repository

### 1. **zimbra_monthly_report.pl**
Script che genera un report mensile in formato HTML, estraendo i dati da MySQL e inviandolo via email.

### 2. **zimbra_csv_mailer.pl**
Script per l'invio automatico del report giornaliero in formato CSV tramite email, con supporto per SMTP con e senza autenticazione.

### 3. **zimbra_db_insert_example.pl**
Script di esempio per l'inserimento manuale o automatizzato dei dati nel database MySQL a partire da un file CSV o altra sorgente.

### 4. **zimbra_sql_schema.sql**
Struttura SQL per la tabella `zimbra_collect` e la vista `Report`, utilizzate dagli script per la memorizzazione e l'analisi dei dati.

### 5. **zimbra_usage_report.pl**
Script principale per la raccolta dei dati direttamente da Zimbra e il caricamento su MySQL.

### 6. **zimbra_usage_report_csv.pl**
Script alternativo che genera un report CSV giornaliero, leggendo direttamente i dati da Zimbra, con log dettagliato.

### 7. **README.md**
Questo file, che spiega in dettaglio il funzionamento e la configurazione del toolkit.

### 8. **.gitignore**
File per escludere file temporanei e di output durante il versionamento con Git.

### 9. **LICENSE**
Licenza GPLv3 del progetto.

## Requisiti

- Perl 5
- Moduli Perl:
  - DBI
  - DBD::mysql
  - MIME::Lite
  - Net::SMTPS
  - HTML::Table::FromDatabase
- MySQL/MariaDB
- Accesso amministrativo a un server Zimbra

**Nota importante:**
Zimbra include di default alcuni moduli Perl nei propri percorsi specifici, pertanto negli script è presente questa riga:

```perl
use lib '/opt/zimbra/common/lib/perl5/x86_64-linux-thread-multi';
```

Questa istruzione consente di caricare correttamente i moduli Perl inclusi con Zimbra, garantendo la compatibilità immediata senza necessità di installazione aggiuntiva.

## Funzionamento

1. **Raccolta Dati:**
   - Gli script leggono le informazioni sugli account Zimbra e calcolano i totali giornalieri.
   - I dati vengono salvati nella tabella `zimbra_collect` o in un file CSV.

2. **Invio Report Giornaliero:**
   - Lo script giornaliero invia via email il CSV con il report.

3. **Report Mensile:**
   - Lo script mensile estrae i dati aggregati del mese precedente e li invia via email in formato HTML.

4. **Personalizzazione SMTP:**
   - Gli script supportano sia SMTP autenticato che non autenticato.

## Configurazione

1. Modifica i parametri di connessione al database nei rispettivi script.
2. Configura i parametri SMTP e le email di destinazione.
3. Pianifica l'esecuzione degli script tramite `cron` o altri sistemi di automazione.

## Installazione

1. Clona o scarica il repository.
2. Installa i moduli Perl richiesti (se non già presenti in Zimbra).
3. Configura i parametri nei file Perl.
4. Crea le tabelle nel database MySQL usando `zimbra_sql_schema.sql`.

## Esempio Cron

### Per la versione che carica su DB:
```bash
0 2 * * * /usr/bin/perl /percorso/zimbra_usage_report.pl
```

### Per la versione che genera il CSV:
```bash
0 2 * * * /usr/bin/perl /percorso/zimbra_usage_report_csv.pl
```

## Licenza

Questo progetto è distribuito sotto licenza **GNU GPL v3**. Puoi trovare il testo completo della licenza nel file [LICENSE](LICENSE) incluso nel repository.

---

> Progetto sviluppato e mantenuto da Samuele "Sem" Bosco
> Contatti: sem@fiberland.it
> Repository GitHub: [https://github.com/Fiberland/zimbra-stats](https://github.com/Fiberland/zimbra-stats)

---

## Copyright

```
Copyright (C) 2024  Samuele "Sem" Bosco

Questo programma è software libero; puoi ridistribuirlo e/o
modificarlo nei termini della GNU General Public License
come pubblicata dalla Free Software Foundation; versione 3
della Licenza, o (a tua scelta) una versione successiva.

Questo programma è distribuito nella speranza che possa essere utile,
ma SENZA ALCUNA GARANZIA; senza nemmeno la garanzia implicita di
COMMERCIABILITÀ o IDONEITÀ PER UNO SCOPO PARTICOLARE. Per maggiori dettagli
consulta la GNU General Public License.

Dovresti aver ricevuto una copia della GNU General Public License
insieme a questo programma; in caso contrario, visita <https://www.gnu.org/licenses/>.
```

