# Project: Pharma Supply Chain / Sales Analysis (SQL)

## Initial dataset assessment

### Nota sul dataset
I dati utilizzati in questo progetto sono stati scaricati da Kaggle. Non è stato possibile recuperare il link originale al momento della stesura di questo README; il dataset non rappresenta un'azienda reale — ogni riferimento a prodotti farmaceutici, vendite o budget è puramente di scenario, a fini didattici.

**Nota tecnica:** i file originali distinguevano le vendite 2023-2024 (`train`) dal 2025 (`test`), nomenclatura tipica di un dataset pensato per esercizi di forecasting/modeling predittivo. In questo progetto i tre anni sono trattati come storico continuo per un'analisi di tipo budget vs actual, che non riguarda il forecasting.

Progetto realizzato per dimostrare competenze SQL (CTE, CASE, aggregazioni, gestione di dataset multi-tabella) applicate a un caso di business realistico, come primo progetto di portfolio.

Dataset composto da 4 CSV grezzi (`financial_plan`, `products_parameters`, `sales_train_2023_2024`, `sales_test_2025`), collegati tramite la chiave naturale `ProductID` (250 prodotti). I dati sono realistici — formato wide (mesi/anni come colonne), colonne sovrapposte/duplicate tra tabelle — rendendolo un buon candidato per un progetto SQL/GitHub pubblicabile, poiché richiede decisioni di modellazione genuine (normalizzazione, star schema), non solo join semplici su dati già puliti.

---

## Decisioni di modellazione

**Decisione 1 — Star Schema**
- Dimension table: `products_parameters` → attributi statici/anagrafici di ogni prodotto
- Fact table: `financial_plan`, `sales`, `inventory` → misure variabili nel tempo, collegate alla dimensione solo via `ProductID`

Criterio guida: statico (non cambia nel tempo) vs. dinamico (varia per anno/mese).

**Decisione 2 — Product_name rimosso dalle fact table**
Attributo descrittivo, non temporale → mantenuto solo in `products_parameters`, recuperabile via JOIN. Rimosso da `sales`, `inventory`, `financial_plan`.

**Decisione 3 — Price_PLN_per_unit centralizzato in products_parameters**
Duplicato tra `financial_plan` e `products_parameters` con valori identici. Test di normalizzazione: il prezzo non cambia tra Plan_2023/2024/2025, quindi è un attributo di prodotto (dimensione), non di piano (fact). Rimosso da `financial_plan`.

**Decisione 4 — Wide → long format**
Le tabelle sorgente (wide, mesi come colonne) sono state convertite in formato long (`ProductID, date, quantity`) per sales e inventory, per facilitare join, aggregazione e UNION tra periodi (2023-24 e test 2025). `financial_plan` resta wide inizialmente (granularità annuale, nessun beneficio immediato a "spacchettarla") — vedi però la sezione successiva sulla sua evoluzione a long.

**Decisione 5 — Naming colonna quantità**
Verificato che `sales_2324_long` / `sales_train_2025_long` usano `quantity_sales`, mentre `inventory_2324_long` / `inventory_test_2025_long` usano `inventory_level` — nomi distinti e corretti, nessuna ambiguità residua (punto precedentemente aperto, ora chiuso).

**Decisione 6 — financial_plan finalizzata (fase wide)**
`Product_name` e `Price_PLN_per_unit` rimossi definitivamente. Struttura intermedia: `ProductID, Plan_2023_units, Plan_2024_units, Plan_2025_units, Plan_2023_PLN, Plan_2024_PLN, Plan_2025_PLN`.

---

## Data quality check — products_parameters

Verificato: 250 `ProductID` unici (nessun duplicato), zero valori nulli su tutte le colonne, nessun valore anomalo (zero/negativo) in `Price_PLN_per_unit` (min 8.00, max 220.81). Tabella confermata pronta come dimension table centrale. Nessuna trasformazione necessaria — solo verifica.

---

## Schema finale

| Tabella | Ruolo | Colonne | File |
|---|---|---|---|
| products_parameters | Dimension | ProductID, Product_name, Storage_cost, Shelf_life, Lead_time, Safety_stock, Price | `products_parameters.csv` |
| financial_plan | Fact | ProductID, Year, PLN, units | `financial_plan_2324_final.csv`, `financial_plan_2025_final.csv` |
| sales | Fact | ProductID, date, quantity_sales | `sales_2324_long.csv`, `sales_train_2025_long.csv` |
| inventory | Fact | ProductID, date, inventory_level | `inventory_2324_long.csv`, `inventory_test_2025_long.csv` |

---

## Evoluzione dello schema: da financial_plan wide a formato long

### Il problema
Lo stakeholder ha richiesto un confronto tra vendite effettive e piano finanziario, prodotto per prodotto, per il 2023 e il 2024. Le vendite (`sales_2324_long`) sono in formato long, con una riga per prodotto/mese — la granularità naturale per aggregarle a livello annuale con `SUM()` e `GROUP BY`.

`financial_plan`, invece, era in formato wide: una riga per prodotto, con colonne separate per ogni anno e metrica (`Plan_2023_units`, `Plan_2024_units`, `Plan_2025_units`, `Plan_2023_PLN`, `Plan_2024_PLN`, `Plan_2025_PLN`).

### Perché il formato wide era un limite
Il join tra le vendite aggregate (long, chiave `ProductID + year`) e il piano (wide, chiave solo `ProductID`) non poteva avvenire su entrambe le dimensioni contemporaneamente: mancando una colonna `year` esplicita in `financial_plan`, non era possibile agganciare "vendite 2023 di P001" al "piano 2023 di P001" senza logica condizionale aggiuntiva (es. `CASE WHEN`) per ogni anno — soluzione poco scalabile e non coerente con lo schema delle altre fact table del progetto.

### La decisione
`financial_plan` è stata trasformata da wide a long e suddivisa in due file, seguendo lo stesso pattern già adottato per sales/inventory (dati storici 2023-2024 separati dai dati 2025):
- `financial_plan_2324_final.csv`: colonne `ProductID, Year, PLN, units`
- `financial_plan_2025_final.csv`: stessa struttura, dati del solo 2025

La trasformazione è stata eseguita in Python (Google Colab) tramite `melt` (wide → long) seguito da `pivot` (per separare le misure `units` e `PLN` in colonne distinte sulla stessa riga prodotto-anno), mantenendo `units` e `PLN` nella stessa tabella perché condividono la stessa granularità e la stessa fonte dati — a differenza di sales/inventory, che sono fatti concettualmente distinti (flusso vs stock).

### Nota di apprendimento
Durante la trasformazione, la colonna `year` — ottenuta come stringa dal nome della colonna originale (es. "2023" estratto da "Plan_2023_units") — è stata inizialmente convertita per errore in formato datetime, per abitudine dovuta al lavoro precedente con le colonne data mensili di `sales_2324_long`. Questo avrebbe introdotto un'incoerenza di tipo rispetto a `EXTRACT(YEAR FROM date)`, già usato altrove nel progetto per ottenere l'anno come intero, complicando inutilmente i join futuri. La colonna è stata poi corretta e mantenuta come `INTEGER`, garantendo coerenza di tipo con il resto dello schema.

---

## Known issues — trovati e corretti

Durante la revisione dei notebook di pulizia sono emersi tre problemi tecnici, non di modellazione ma di implementazione:

1. **Colonna `index` spuria in `financial_plan_2025_final`.** Causata da una doppia chiamata a `reset_index()` sullo stesso DataFrame: la prima trasformava correttamente l'indice `ProductID, Year` (creato dal pivot) in colonne; la seconda, applicata a un DataFrame che aveva già un indice numerico standard, generava una colonna aggiuntiva chiamata `index`. Corretto rimuovendo la chiamata duplicata.

2. **Rename di colonna eseguito dopo il salvataggio, in `sales_train_2025`.** La colonna `quantity_sales_2025` veniva rinominata in `quantity_sales` solo dopo un primo salvataggio/download del CSV, che quindi conteneva ancora il nome vecchio. Corretto spostando il rename prima dell'unico salvataggio finale.

3. **Secondo salvataggio malformato, nello stesso notebook.** Un salvataggio successivo al punto 2 mancava sia dell'estensione `.csv` nel nome del file sia del parametro `index=False`, introducendo una colonna indice non voluta. Risolto consolidando in un unico salvataggio corretto, eseguito dopo il rename.

Nessuno di questi problemi ha impattato la struttura finale dei dati riportata nello schema sopra — sono stati intercettati e corretti prima della pubblicazione dei CSV finali.

---

## Verifiche di qualità eseguite su tutti i notebook

- Controllo duplicati (`duplicated().sum()`)
- Controllo valori mancanti (`isnull().sum()`)
- Controllo tipi di dato (`dtypes` / `info()`)
- Controllo range valori su colonne numeriche chiave (es. `Price_PLN_per_unit`, `describe()`)
