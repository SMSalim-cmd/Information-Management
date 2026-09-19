# Online samenwerken instellen

Zonder deze stappen werkt de app gewoon op één laptop, precies zoals eerst. Volg dit
stappenplan als je met de hele groep tegelijk in dezelfde productierun wilt meten,
ieder op zijn eigen telefoon. Je doet dit **één keer**; daarna is het per run nog maar
één code delen.

Tijd: ongeveer 15 minuten. Kosten: niets — alles past ruim in de gratis pakketten.

---

## Waarom Supabase?

| | Supabase | Firebase Realtime Database |
|---|---|---|
| Database | Postgres — echte tabellen, SQL, makkelijk te exporteren naar Excel/Power BI | JSON-boom |
| Gratis pakket | ruim voldoende (500 MB database, 2 GB verkeer per maand) | ook ruim, maar per verkeer afgerekend |
| Beveiliging zonder accounts | Row Level Security-regels in SQL, te lezen en te controleren | security rules in een eigen taal |
| Toegang zonder library | gewone REST-API — de app heeft geen enkele library nodig | vergt de Firebase-SDK |
| Voor een verslag | je kunt het SQL-schema en de policies letterlijk in je bijlage zetten | lastiger uit te leggen |

Doorslaggevend voor dit project: de append-only eventtabel is in Postgres precies dat wat
je in je verslag wilt laten zien, en de app kan er met gewone `fetch`-aanroepen bij.
Dat scheelt een externe afhankelijkheid, dus de applicatie blijft ook offline werken.

## Hoe de synchronisatie werkt

1. **Bron van waarheid is de tabel `events`.** Elk tikje (start, pauze, gereed, QC, afkeur)
   is één regel. Er wordt nooit een regel gewijzigd of verwijderd — een verkeerde klik
   wordt teruggedraaid met een correctie-event. Alle KPI's worden uit die regels berekend,
   niet uit bijgewerkte totalen. Daardoor kunnen vier mensen tegelijk schrijven zonder
   dat er iets botst.
2. **Elk event heeft een UUID die de telefoon zelf genereert.** Wordt hetzelfde event door
   een hapering twee keer verstuurd, dan herkent de database het aan die sleutel en slaat
   het maar één keer op.
3. **Ophalen gebeurt met een cursor.** De app vraagt elke twee seconden "alles wat er na dit
   tijdstip bij is gekomen" — met een kleine overlap terug in de tijd, zodat er nooit een
   event tussendoor kan glippen.
4. **Klokcorrectie.** Bij het verbinden vraagt de app drie keer de servertijd op en meet de
   afwijking van de telefoonklok. Alle timestamps worden daarvoor gecorrigeerd. Loopt een
   telefoon 40 seconden voor, dan blijven de metingen toch kloppen.
5. **Offline.** Valt de wifi weg, dan loopt de timer lokaal gewoon door en gaan de events in
   een wachtrij. Zodra er weer verbinding is, wordt de wachtrij automatisch verstuurd. De
   statusbalk bovenin laat zien wat er aan de hand is: Online, Synchroniseren of Offline.

---

## Stap 1 — Supabase-project aanmaken

1. Ga naar <https://supabase.com> en maak een gratis account (inloggen met GitHub kan ook).
2. Klik op **New project**.
   - Name: `innovo-motors`
   - Database password: verzin er een en bewaar hem (je hebt hem verder niet nodig).
   - Region: **West EU (Ireland)** of **Central EU (Frankfurt)** — dat scheelt reactietijd.
3. Klik op **Create new project** en wacht ongeveer twee minuten.

## Stap 2 — Het SQL-script draaien

1. Open in het linkermenu **SQL Editor** → **New query**.
2. Open het bestand `supabase.sql` uit deze map, kopieer de **hele** inhoud en plak die
   in de editor.
3. Klik op **Run**. Je hoort "Success. No rows returned" te zien.

Dit maakt twee tabellen (`runs` en `events`), de beveiligingsregels en twee functies:
`join_run` (meedoen met een runcode) en `server_now` (klokcorrectie).

## Stap 3 — De sleutels ophalen

1. Ga naar **Project Settings** → **API** (of **Data API**).
2. Noteer:
   - **Project URL** — iets als `https://abcdefghijkl.supabase.co`
   - **anon public** key — een lange tekst die begint met `eyJ...`

> De anon key is bedoeld om publiek te zijn. De beveiliging zit in de Row Level Security
> uit stap 2: zonder runcode kun je géén enkele run lezen, wijzigen of wissen. Gebruik nooit
> de `service_role` key in de app — die omzeilt alle regels.

## Stap 4 — De sleutels in `config.js` zetten

Open `config.js` uit deze map en vul de twee waarden in:

```js
window.INNOVO_CONFIG = {
  supabaseUrl: 'https://abcdefghijkl.supabase.co',
  supabaseAnonKey: 'eyJhbGciOi...'
};
```

Daarmee brengt de site de databasegegevens zelf mee: **iedereen die de URL opent is meteen
verbonden** en hoeft alleen nog een runcode in te vullen. Je hoeft dus niet op vier telefoons
sleutels over te typen.

Laat je `config.js` leeg, dan werkt de app gewoon lokaal en kan iedereen de gegevens alsnog
zelf invullen bij **INSTELLINGEN → Online samenwerken → Database instellen**.

## Stap 5 — De app publiceren

Zodat iedereen hem via een URL op zijn telefoon kan openen. Kies één van de drie.

### Netlify Drop (het snelst — geen account nodig om te beginnen)

1. Zet deze bestanden samen in één map: `index.html`, `config.js`, `sw.js`,
   `manifest.webmanifest` en de drie `icon-*.png`-bestanden.
2. Ga naar <https://app.netlify.com/drop> en sleep die map in het venster.
3. Je krijgt direct een URL. Via **Site configuration → Change site name** maak je er
   bijvoorbeeld `innovo-motors.netlify.app` van.

Een nieuwe versie zetten? Sleep de map opnieuw naar hetzelfde project via
**Deploys → Drag and drop your site output folder here**.

### Netlify gekoppeld aan GitHub (werkt zichzelf bij)

1. **Add new site → Import an existing project → GitHub**, kies deze repository.
2. Branch: `claude/production-measurement-dashboard-thd7n1` (of `main` als je die branch
   eerst samenvoegt). Build command leeg laten, publish directory `.` — `netlify.toml`
   in de repo vult dit al voor je in.
3. Elke push werkt de site automatisch bij.

> Let op: als je de repository openbaar maakt, staat je anon key ook openbaar in `config.js`.
> Dat mag: die sleutel is publiek bedoeld en de beveiliging zit in de Row Level Security.
> Wil je hem toch niet in Git hebben, gebruik dan Netlify Drop en houd `config.js` lokaal.

### GitHub Pages

1. Zet `index.html`, `config.js`, `sw.js`, `manifest.webmanifest` en de drie
   `icon-*.png`-bestanden in de hoofdmap van de repository en push naar `main`.
2. Ga op GitHub naar **Settings → Pages**.
3. Bij *Source*: **Deploy from a branch**, branch **main**, map **/ (root)**. Klik **Save**.
4. Na een minuut staat de app op `https://<gebruikersnaam>.github.io/<repo>/`.

### Vercel

1. <https://vercel.com> → **Add New → Project** → koppel de repository.
2. Framework preset: **Other**, build command leeg laten, output directory `.`.
3. **Deploy**.

> Belangrijk: open de app via `https://…`, niet als bestand vanaf de laptop. Alleen dan
> werken de service worker, "toevoegen aan beginscherm" en het wakker houden van het scherm.

## Stap 6 — Op het beginscherm zetten (PWA)

- **Android/Chrome**: menu (drie puntjes) → *App installeren* of *Toevoegen aan startscherm*.
- **iPhone/Safari**: deelknop → *Zet op beginscherm*.

De app opent daarna schermvullend, zonder adresbalk, en start ook als het netwerk traag is.

## Stap 7 — Samen meten

1. **Eén persoon** start de run: **+ Nieuwe run** → kies de week uit de orderlijst →
   vink *Online run* aan → **Run starten**. Er verschijnt een runcode, bijvoorbeeld
   `INNOVO-4821`. Controleer of de balk bovenin op **Online** staat.
2. **De anderen** openen dezelfde URL op hun telefoon, tikken op **Meedoen**, vullen de
   code in en kiezen hun werkstation. Meer hoeven zij niet in te stellen.
3. Iedereen ziet nu alleen zijn eigen station, schermvullend. Alles wat je tikt is binnen
   enkele seconden zichtbaar bij de rest en op het dashboard.
4. Degene die coördineert gebruikt de laptop: daar staan alle vier de stations naast elkaar
   plus het volledige dashboard.

## Stap 8 — Eerdere metingen meenemen

Staan er al runs in je localStorage van vóór deze versie? Ga naar
**DATA → Back-up → Lokale runs uploaden naar de database**. Elke run krijgt een eigen
runcode; de lokale kopie blijft gewoon staan.

---

## Problemen oplossen

| Melding | Wat het betekent |
|---|---|
| *De functie server_now() reageert niet* | Het SQL-script is niet (helemaal) gedraaid. Draai `supabase.sql` opnieuw. |
| *Geen run gevonden met code …* | Typefout, of de run is op een ánder Supabase-project aangemaakt. Controleer of alle apparaten dezelfde Project URL gebruiken. |
| *new row violates row-level security policy* | Je schrijft naar een run waarvan je het id niet hebt. Doe opnieuw mee met de runcode. |
| Statusbalk blijft op *Synchroniseren…* | Er is wel internet maar de database antwoordt niet. De metingen lopen lokaal door en worden later alsnog verstuurd — je verliest niets. |
| Statusbalk blijft op *Lokaal* terwijl `config.js` is ingevuld | De telefoon heeft een oude versie in de cache. Ververs de pagina één keer hard, of verwijder de app van het beginscherm en zet hem opnieuw neer. |
| Je hebt eerder handmatig andere sleutels ingevuld | Die eigen instelling wint van `config.js`. Ga naar INSTELLINGEN → Online samenwerken → **Verbinding vergeten** en ververs de pagina. |
| Iedereen ziet elkaar, maar traag | Normaal is twee seconden. Op een heel slecht netwerk kan het oplopen; de volgorde van de metingen blijft kloppen omdat de tijd van de meting zelf wordt opgeslagen, niet de tijd van verzenden. |

## Wat er wél en niet beveiligd is

- Zonder runcode kun je **geen enkele run** en **geen enkel event** lezen, wijzigen of wissen.
- Iedereen die de runcode heeft, mag in die run meten. Dat is precies de bedoeling: geen
  wachtwoorden tijdens het assembleren.
- Events kunnen door niemand worden gewijzigd of verwijderd — er is bewust geen update- of
  delete-regel op de tabel `events`. Een verkeerde klik corrigeer je met "ongedaan maken",
  wat een nieuw correctie-event toevoegt.
- Deel je runcode dus niet met andere groepen, en maak per productieronde een nieuwe run.
