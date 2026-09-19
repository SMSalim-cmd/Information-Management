/* =========================================================================
   Innovo Motors — databasegegevens van de gepubliceerde site
   -------------------------------------------------------------------------
   Vul hier de Project URL en de anon public key van je Supabase-project in.
   Iedereen die de site opent is dan meteen verbonden en hoeft alleen nog een
   runcode in te vullen. Laat je dit leeg, dan werkt de app gewoon lokaal en
   kan iedereen de gegevens alsnog zelf invoeren bij INSTELLINGEN.

   De anon key is bedoeld om publiek te zijn. De beveiliging zit in de Row
   Level Security-regels uit supabase.sql: zonder runcode is er geen enkele
   run te lezen, te wijzigen of te wissen. Zet hier NOOIT de service_role key
   neer — die omzeilt alle regels.
   ========================================================================= */
window.INNOVO_CONFIG = {
  supabaseUrl: '',        // bijv. 'https://abcdefghijkl.supabase.co'
  supabaseAnonKey: ''     // de lange sleutel die begint met eyJ...
};
