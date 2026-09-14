# Innovo Motors — Production Measurement Dashboard

Webapplicatie voor de module **Information Management** (Logistics Management, BUas), case
*Innovo Motors – From startup to scale-up*.

Met z'n vieren tegelijk meten, ieder op zijn eigen telefoon, in dezelfde productierun.
Werkt ook volledig zelfstandig op één laptop.

| Bestand | Waarvoor |
|---|---|
| `index.html` | de volledige applicatie — open of publiceer alleen dit bestand |
| `SETUP.md` | stappenplan om online samen te werken en de app te publiceren |
| `supabase.sql` | databaseschema en beveiligingsregels, in één keer te draaien |
| `sw.js`, `manifest.webmanifest`, `icon-*.png` | maken er een installeerbare app (PWA) van |

## Snel starten

### Op één laptop (geen installatie nodig)

Open `index.html` in een browser. Klaar.

### Met de hele groep tegelijk

1. Volg eenmalig `SETUP.md` (gratis Supabase-project, SQL-script, app publiceren).
2. Eén persoon: **+ Nieuwe run** → kies de week uit de orderlijst → *Online run* aanvinken.
   Er verschijnt een runcode, bijvoorbeeld `INNOVO-4821`.
3. De anderen openen dezelfde URL, tikken op **Meedoen**, vullen de code in en kiezen hun
   werkstation. Ze zien daarna alleen hun eigen station, schermvullend.
4. De coördinator houdt de laptop erbij: alle vier de stations naast elkaar plus het dashboard.

## Meten tijdens de run

Per werkstation: **START** → **PAUZE/WACHTEN** (met reden) → **HERVATTEN** → **GEREED** →
**KWALITEITSCONTROLE**. Na GEREED schuift je station automatisch door naar de volgende motor
uit de order; START staat meteen klaar. Fout getikt? **Ongedaan maken** draait de laatste
actie terug.

## Hoe de meting werkt

Elke tik wordt opgeslagen als een **event met een echte timestamp**. Alle KPI's worden telkens
opnieuw uit die eventlog berekend — niets wordt "live" bijgehouden. Daardoor:

- blijven de tijden kloppen als de browser hapert, je ververst, het scherm vergrendelt of
  de wifi wegvalt;
- kunnen vier mensen tegelijk schrijven zonder dat metingen elkaar overschrijven;
- kun je de ruwe events exporteren en de berekening in Excel zelf natrekken.

Events worden nooit gewijzigd of verwijderd (append-only). "Ongedaan maken" voegt een
**correctie-event** toe; het oorspronkelijke event blijft zichtbaar in de historie.
Telefoonklokken die voor- of achterlopen worden bij het verbinden gemeten en gecorrigeerd.
Valt het netwerk weg, dan loopt de timer lokaal door, gaan de events in een wachtrij en
worden ze automatisch verstuurd zodra er weer verbinding is.

## Definities (meetprotocol)

| Begrip | Definitie in deze app |
|---|---|
| Cycle time werkstation | `GEREED − START` (brutotijd, inclusief wachten binnen de handeling) |
| Actieve tijd | som van de werksegmenten (cycle time minus geregistreerde wachttijd) |
| Wachttijd | som van de pauzesegmenten, met reden en TIMWOOD-categorie |
| Rework-tijd | apart gemeten hersteltijd na afkeur, telt niet mee in de cycle time |
| Lead time motor | eerste start van de motor → laatste goedkeuring van het laatste station |
| Overdrachtswachttijd | gereed bij het vorige station → start bij het volgende, per motor |
| Throughput | complete motoren ÷ verstreken runtijd (per uur) |
| Productiviteit | complete motoren ÷ daadwerkelijk gewerkte uren (alle stations samen) |
| First Pass Yield | complete motoren zonder enige afkeur ÷ alle complete motoren |
| WIP | motoren die gestart zijn maar nog niet compleet en goedgekeurd |
| Takt time | beschikbare productietijd ÷ klantvraag |
| Bezettingsgraad | actieve tijd ÷ verstreken runtijd, per station |
| Wachttijdpercentage | wachttijd ÷ verstreken runtijd, per station |
| Bottleneck | station met de hoogste gemiddelde cycle time |
| Lijnbalans | Σ gemiddelde cycle times ÷ (aantal stations × hoogste gemiddelde cycle time) |
| Flow-efficiëntie | werktijd ÷ (werktijd + wachttijd + rework) |
| Control chart | gemiddelde, standaarddeviatie en gemiddelde ± 3σ over de gekozen meting |

## Pagina's

**PRODUCTIE** meetscherm met orderwachtrij · **DASHBOARD** KPI's, bottleneck, takt, trends,
uitsplitsing per motorvariant · **KWALITEIT** FPY, fouten, rework · **VERSPILLING** TIMWOOD,
wachtredenen, overdrachtswachttijd · **PROCESSTABILITEIT** control chart ·
**ORDERS & MATERIAAL** weekorders, BOM, materiaalbehoefte, picklijsten ·
**VERGELIJK RUNS** week 1 t/m 9 naast elkaar · **DATA** export, back-up, eventlog ·
**INSTELLINGEN** namen, redenen, foutcategorieën, orders, BOM, database.

## Orders en Bill of Materials

De orders van Factory 2 voor week 1 tot en met 9 en het volledige assortiment
(M-148030 t/m M-148041) zitten vast in de applicatie, inclusief de eigenschappen per variant:
kleur, Road- of Cross-banden en zadel, en normaal of wide stuur.

> **De artikelnummers in de Bill of Materials moeten nog ingevuld worden.** De officiële
> BOM-bijlage van Innovo (vanaf pagina 107) zat niet bij het aangeleverde document. De
> onderdelenlijst per variant is daarom afgeleid uit de productlijst en bevat bewust géén
> verzonnen artikelnummers. Vul ze aan bij **INSTELLINGEN → Bill of Materials**, of
> importeer ze in één keer als JSON. Daarna kloppen de materiaalbehoefte en de picklijsten
> automatisch.

Orders en BOM zijn volledig aanpasbaar zonder de code te wijzigen: toevoegen, wijzigen,
verwijderen, importeren en exporteren als JSON.

## Let op

- Zonder online database staat de data in **deze browser op dit apparaat**. Maak na elke
  meetsessie een back-up via **DATA → Back-up exporteren**.
- Eerdere lokale runs upload je met één knop: **DATA → Lokale runs uploaden naar de database**.
- **Demo-data** (DATA → Demo-data laden) is gegenereerde voorbeelddata, overal gemarkeerd met
  een `DEMO`-label. Gebruik die nooit als meetresultaat in je verslag.
