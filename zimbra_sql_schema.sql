-- Struttura tabella raccolta statistiche giornaliere
CREATE TABLE zimbra_collect (
    date DATE NOT NULL,
    domain VARCHAR(255) NOT NULL,
    cos VARCHAR(50) NOT NULL,
    total INT NOT NULL,
    PRIMARY KEY (date, domain, cos)
);

-- Vista per report mensile
CREATE VIEW Report AS
SELECT 
    YEAR(date) AS thisYear,
    MONTH(date) AS thisMonth,
    domain,
    cos,
    SUM(total) AS totale
FROM zimbra_collect
GROUP BY thisYear, thisMonth, domain, cos;
