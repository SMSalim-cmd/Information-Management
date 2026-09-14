# Innovo Motors — Production Measurement Dashboard

Webapplicatie voor de module **Information Management** (Logistics Management, BUas), case
*Innovo Motors – From startup to scale-up*.

Open `index.html` in een browser. Er is geen server, geen installatie en geen internet nodig:
alles zit in dat ene bestand en de data wordt opgeslagen in de `localStorage` van de browser.

## Snel starten tijdens een productieronde

1. **INSTELLINGEN** → controleer de namen en werkstations (standaard: Viggo – voorwiel + stuur,
   Noah – achterwiel, Stan – tank + stoel, Pepijn – hoofdassemblage).
2. **+ NIEUWE RUN** → naam, datum, weeknummer, doelaantal, beschikbare tijd en klantvraag.
   De takt time wordt automatisch berekend.
3. **PRODUCTIE** → **+ NIEUWE MOTOR** voor Motor 001, 002, …
4. Per werkstation: **START** → **PAUZE/WACHTEN** (met reden) → **HERVATTEN** → **GEREED** →
   **KWALITEITSCONTROLE**. De vier timers lopen onafhankelijk en gelijktijdig.
5. Fout geklikt? **↶ Ongedaan maken** rechtsboven verwijdert de laatste registratie en
   herberekent alles.
6. Na afloop: **DATA** → exporteer CSV/JSON voor Excel of Power BI, en maak een back-up.

## Hoe de meting werkt

Elke klik wordt opgeslagen als een **event met een echte timestamp**. Alle KPI's worden telkens
opnieuw uit die eventlog berekend — niets wordt "live" bijgehouden. Daardoor:

- blijven de tijden kloppen als de browser hapert, je ververst of het tabblad even wegvalt;
- kun je de laatste actie ongedaan maken zonder dat de rest scheeftrekt;
- kun je de ruwe events exporteren en de berekening in Excel zelf natrekken.

## Definities (meetprotocol)

| Begrip | Definitie in deze app |
|---|---|
| Cycle time werkstation | `GEREED − START` (brutotijd, inclusief wachten binnen de handeling) |
| Actieve tijd | som van de werksegmenten (cycle time minus geregistreerde wachttijd) |
| Wachttijd | som van de pauzesegmenten, met reden en TIMWOOD-categorie |
| Rework-tijd | apart gemeten hersteltijd na afkeur, telt niet mee in de cycle time |
| Lead time motor | eerste start van de motor → laatste goedkeuring van het laatste station |
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

**PRODUCTIE** meetscherm · **DASHBOARD** KPI's, bottleneck, takt, trends · **KWALITEIT** FPY,
fouten, rework · **VERSPILLING** TIMWOOD en wachtredenen · **PROCESSTABILITEIT** control chart ·
**VERGELIJK RUNS** week 1 t/m 4 naast elkaar · **DATA** export, back-up, eventlog ·
**INSTELLINGEN** namen, redenen, foutcategorieën.

## Let op

- De data staat in **deze browser op deze laptop**. Maak na elke meetsessie een back-up via
  **DATA → Back-up exporteren**.
- **Demo-data** (DATA → Demo-data laden) is gegenereerde voorbeelddata, duidelijk gemarkeerd met
  een `DEMO`-label. Gebruik die nooit als meetresultaat in je verslag.
