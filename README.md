# Innovo Motors — Production Measurement Dashboard

Webapplicatie voor de module **Information Management** (Logistics Management, BUas), case
*Innovo Motors – From startup to scale-up*.

Met z'n vieren tegelijk meten, ieder op zijn eigen telefoon, in dezelfde productierun.
Werkt ook volledig zelfstandig op één laptop.

| Bestand | Waarvoor |
|---|---|
| `index.html` | de volledige applicatie — open of publiceer alleen dit bestand |
| `SETUP.md` | stappenplan om online samen te werken en de app te publiceren |
| `supabase.sql` | databaseschema en beveiligingsregels, in één keer te draaien — sinds de eerste keer onveranderd |
| `config.js` | de Supabase-gegevens van de gepubliceerde site — één keer invullen, dan hoeft niemand ze op zijn telefoon in te typen |
| `netlify.toml` | zorgt dat Netlify de map zonder build publiceert |
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
**KWALITEITSCONTROLE**.

Na GEREED schuift je station **vanzelf door** naar de volgende motor uit de wachtrij:

- Is het dezelfde modelcode en kun je meteen verder, dan loopt de timer direct. Geen extra klik.
- Kun je nog niet verder, dan gaat het station automatisch op **Wachten**. Die tijd telt als
  wachttijd en niet als werktijd, en de cycle time begint pas als je echt begint. Is de vorige
  processtap nog niet klaar, dan vult de app zelf de reden in en onthoudt op wie je wacht.
- Komt er een **ander model**, dan wordt er niet meteen gestart maar gaat de motor op
  *Omstellen naar ander model*. Je drukt zelf op START zodra je hebt omgesteld. Precies die
  tussentijd is de omsteltijd, en de cycle time van de eerste motor van de nieuwe batch
  blijft daardoor zuiver.
- Is de wachtrij leeg, dan verschijnt "Alle motoren gereed".

Fout getikt? **Ongedaan maken** draait de laatste actie terug, inclusief het doorschuiven.

De run sluit zichzelf zodra álle stations klaar zijn met álle motoren in de wachtrij; daarna
verschijnt het eindrapport. Op het productiescherm zie je live op wie er nog gewacht wordt.
Eerder stoppen kan met bevestiging, en wordt geregistreerd als voortijdig beëindigd.

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
| Actuele takt | verstreken runtijd ÷ voltooide motoren — ons werkelijke tempo |
| Laatste takt | tijd tussen de laatste twee voltooide motoren |
| Gepland aantal | verstreken productietijd ÷ takt time |
| Veroorzaakte wachttijd | tijd dat anderen stilstonden doordat dít station nog niet klaar was |
| Bottleneck | station met de meeste veroorzaakte wachttijd (valt terug op cycle time zolang er nog geen wachttijd is toegerekend) |
| Lijnbalans | Σ gemiddelde cycle times ÷ (aantal stations × hoogste gemiddelde cycle time) |
| Flow-efficiëntie | werktijd ÷ (werktijd + wachttijd + rework) |
| Control chart | gemiddelde, standaarddeviatie en gemiddelde ± 3σ over de gekozen meting |
| Batch | opeenvolgende motoren met dezelfde modelcode in de wachtrij |
| Omsteltijd | per station: gereed bij de laatste motor van een batch → start bij de eerste motor van het volgende model |
| Opstartkosten | som van de cycle times van de eerste motor van een batch min het gemiddelde van de overige motoren in diezelfde batch |
| Beschikbare tijd | de ingeplande productietijd van de run; de aftelklok loopt hierop |
| Binnen de tijd gereed | motoren die vóór het einde van de beschikbare tijd zijn goedgekeurd |

## Pagina's

**PRODUCTIE** meetscherm met aftelklok, tempobalk, batchstructuur en orderwachtrij ·
**DASHBOARD** KPI's, bottleneck, takt, planning versus output, trends, omstellen en
opstartkosten, uitsplitsing per motorvariant en per modelcode · **EINDRAPPORT**
tijdsverantwoording, kwaliteitsoverzicht per motor, actielijst en verbeteradvies ·
**KWALITEIT** FPY, fouten, rework · **VERSPILLING** TIMWOOD, wachtredenen,
overdrachtswachttijd ·
**PROCESSTABILITEIT** control chart ·
**ORDERS & MATERIAAL** weekorders, BOM, materiaalbehoefte, picklijsten ·
**VERGELIJK RUNS** week 1 t/m 9 naast elkaar, inclusief geïmporteerde metingen ·
**DATA** export, import uit Excel/CSV, back-up, eventlog ·
**INSTELLINGEN** namen, redenen, foutcategorieën, weergave en streeftijden, orders, BOM,
database.

## Batches en modelwissels

Motoren met dezelfde modelcode staan automatisch achter elkaar in de wachtrij; zo'n groep heet
een **batch**. Boven het productiescherm staat de batchstructuur met per batch de modelcode, de
grootte en hoeveel motoren er al af zijn, en op elk stationkaartje en op elke telefoon staat
"motor 3 van 5 in deze batch".

Zodra een station aan de laatste motor van zijn batch begint, verschijnt een waarschuwing met
**wat er per werkstation verandert** — het verschil tussen de twee stuklijsten, dus welke
onderdelen erbij komen, vervallen of in een ander aantal nodig zijn. Zo kan iedereen alvast
klaarleggen wat hij nodig heeft.

De **omsteltijd** wordt apart gemeten en telt als eigen categorie mee in TIMWOOD (standaard
onder *Waiting*, aan te passen bij INSTELLINGEN). Op het dashboard staan het aantal
modelwissels, de totale en gemiddelde omsteltijd, de opstartkosten per batch, een uitsplitsing
van alle KPI's per modelcode en een vergelijking van de eerste motor van een batch met de
overige motoren — daarmee zie je het leereffect binnen een batch.

De volgorde van de batches kies je bij het starten van de run (pijltjes omhoog/omlaag) en pas
je tijdens de run aan met **Wachtrij beheren**. Een batch waarin al gewerkt is, staat vast.
Verschuiven is een gewoon event: er wordt niets gewist en het is ongedaan te maken.

## Aftellen in plaats van optellen

De grote timer telt standaard **af** naar de streeftijd per motor: groen zolang er ruimte is,
oranje in de laatste 20%, rood en knipperend zodra de tijd op is — daarna telt hij negatief
door. Is de beschikbare productietijd van de hele run voorbij, dan verschijnt een
schermvullend **TIJD IS OM – STOPPEN** met geluid en trilsignaal. Boven het productiescherm en
op elke telefoon staat de resterende runtijd en hoeveel tijd er nog per nog te maken motor over
is.

De streeftijd per station stel je in bij **INSTELLINGEN → Weergave**; laat je die leeg, dan
gebruikt de app de takt time. Die streeftijd wordt als event opgeslagen en reist dus mee naar
de telefoons van de anderen. De keuze tussen aftellen en optellen staat per apparaat: iedereen
mag dat zelf instellen zonder dat het de meting of de anderen beïnvloedt.

**De aftelweergave is puur presentatie.** Cycle time, actieve tijd, wachttijd en lead time
worden altijd uit de echte start- en stoptimestamps berekend, dus alle KPI's en exports blijven
hetzelfde of je nu aftelt of optelt. Motoren die pas ná de beschikbare tijd zijn afgemaakt
worden wel apart geteld: het eindrapport laat zien hoeveel tijd er beschikbaar was, hoeveel is
gebruikt, hoeveel over of overschreden is, en of het weekdoel binnen die tijd gehaald is.

## Metingen importeren uit Excel of CSV

Metingen die niet in de app zijn gedaan — een week die op papier is bijgehouden, of een
spreadsheet van een groepsgenoot — lees je in bij **DATA → Data importeren uit Excel**. Download
eerst het sjabloon (Excel of CSV): één regel per motor per werkstation, met start- en
gereedtijd.

De import gaat in drie stappen: bestand kiezen, kolommen koppelen met een controle per regel,
en daarna de run opslaan. De controle meldt in gewoon Nederlands wat er mis is — ontbrekende
motor, gereed vóór de start, onleesbare tijd, onbekend werkstation, een wachttijd die langer is
dan de handeling zelf. Regels met een fout worden overgeslagen, de rest wordt gewoon ingelezen.
Tijden mogen als `09:15`, `9:15:30`, `09.15`, `2026-09-30 09:15`, `30-09-2026 09:15` of als
gewone Excel-tijdcel; wachttijd en rework als `90`, `1:30`, `2 min` of `1:01:30`.

Bestaat er al een run met dezelfde naam of datum, dan kies je zelf: als nieuwe run toevoegen,
samenvoegen met de bestaande run, of de bestaande run vervangen.

Een geïmporteerde run wordt omgezet naar dezelfde events met dezelfde echte timestamps als een
run die je zelf meet, dus alle KPI's, het eindrapport, de exports en de vergelijking tussen
runs werken er onverkort op. Wat we niet letterlijk in het bestand zagen maar hebben afgeleid
(het aanmaken van de motor, een wachtpauze uit een duurkolom, de kwaliteitscontrole) is in de
eventlog gemarkeerd als *afgeleid*, en de run draagt overal het label **geïmporteerd**.

**Keuze voor het lezen van .xlsx:** we gebruiken hiervoor geen externe bibliotheek. Een .xlsx
is een ZIP met XML erin, en beide kan de browser zelf al (`DecompressionStream` en `DOMParser`).
Zo blijft de app één bestand, werkt de import volledig offline — ook zonder CDN — en gaan onze
meetgegevens niet door 900 kB vreemde code heen. Kan een browser geen deflate uitpakken, dan
zegt de app dat en verwijst naar de CSV-variant, die we met een eigen parser lezen.

## Tempo en schema tijdens de run

Boven het productiescherm staat een tempobalk met de vereiste takt time, de **actuele takt**
(ons werkelijke tempo), de **laatste takt** (versnellen of vertragen we?), of we voor of achter
op schema liggen — in motoren én in minuten — en de verwachte eindtijd met de vraag of we die
binnen de beschikbare tijd halen. Per station staat naast het gemiddelde ook het tempo over
de **laatste drie motoren**, zodat je een trend binnen de run ziet in plaats van één gemiddelde.

Op het dashboard staat de planningslijn (recht, op basis van de takt time) naast de werkelijke
output, zodat je ziet wáár je begon achter te lopen.

## Bottleneck en verbeteradvies

De bottleneck wordt bepaald op **veroorzaakte wachttijd**: op wie staat de rest in de praktijk
het langst te wachten? Bij elke wachttijd met de reden "wachten op vorige werkstation" legt de
app vast welk station de motor nog niet had doorgegeven. Daarbij staan ter onderbouwing de
gemiddelde cycle time en de bezettingsgraad, een ranglijst van alle stations, en of het
knelpunt structureel is (bij vrijwel elke motor) of incidenteel.

Na afloop rekent de app de meetgegevens door en geeft maximaal vijf concrete tips, gesorteerd
op geschatte tijdwinst. Elke tip bevat de waarneming met het cijfer erbij, de waarschijnlijke
oorzaak, een concrete actie en de verwachte winst per motor en per run. De tips kijken naar de
veroorzaakte wachttijd, de werkverdeling, de grootste wachtoorzaak en TIMWOOD-categorie, de
variatie in cycle time, fouten en rework, het leereffect en de vergelijking met de vorige run —
inclusief de vraag of het advies van vorige keer geholpen heeft. Het advies wordt bij de run
opgeslagen en is te kopiëren of als tekstbestand te exporteren voor je verslag.

Het leereffect wordt gemeten op de som van de cycle times, niet op de lead time: die loopt
vanzelf op zodra er werk in de wachtrij staat en zegt dus niets over sneller werken.

## Orders en Bill of Materials

De orders van Factory 2 voor week 1 tot en met 9, het volledige assortiment
(M-148030 t/m M-148041) en de **Bill of Materials van Innovo** zitten vast in de applicatie.
Uit de BOM worden automatisch berekend: de materiaalbehoefte per week, de picklijst per
werkstation en de afvinklijst die je op je telefoon naast de timer opent.

De BOM staat er precies in zoals aangeleverd. De bijlage waarschuwt zelf dat er fouten in
kunnen zitten, dus de app vergelijkt alle varianten met elkaar en meldt bij
**ORDERS & MATERIAAL** wat eruit springt — zonder zelf iets te wijzigen:

1. **M-148030 (Road Rocket – Blue) mist het Four-hole bracket ×2** dat alle elf andere
   varianten wél hebben. Eén knop zet het erbij als je die correctie wilt doorvoeren.
2. **Alle varianten hebben 10 moeren tegenover 7 bouten.** Controleer dat bij het uitpakken.

De bijlage vermeldt alleen onderdeelnamen, geen artikelnummers; die kolom kun je zelf
invullen. De indeling van onderdelen over de vier werkstations is onze eigen keuze
(voorband en koplamp bij Viggo, achterband bij Noah, tank en zadel bij Stan, brackets en
bevestigingsmateriaal bij Pepijn) en is met één klik aan te passen.

Orders en BOM zijn volledig aanpasbaar zonder de code te wijzigen: toevoegen, wijzigen,
verwijderen, importeren en exporteren als JSON.

## Let op

- Zonder online database staat de data in **deze browser op dit apparaat**. Maak na elke
  meetsessie een back-up via **DATA → Back-up exporteren**.
- Eerdere lokale runs upload je met één knop: **DATA → Lokale runs uploaden naar de database**.
- **Demo-data** (DATA → Demo-data laden) is gegenereerde voorbeelddata, overal gemarkeerd met
  een `DEMO`-label. Gebruik die nooit als meetresultaat in je verslag.
- De app gaat ervan uit dat het **laatste werkstation de hoofdassemblage** is en de andere
  stations nodig heeft; de overige stations werken zelfstandig. Daarop is het automatisch
  doorschuiven gebaseerd. Wil je een strikte volgorde, kies dat dan bij het starten van de run.
