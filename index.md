@def title = "Wikipedia as data"
@def hascode = true

~~~
<div class="home-page">
<section class="hero" aria-labelledby="hero-title">
  <div class="hero-copy"><span class="kicker">English Wikipedia · April 2026 dump</span>
    <h1 id="hero-title">Every edit.<br>Every <em>protection.</em></h1>
    <p>The full edit history of the English Wikipedia, its protection log and every request for page protection since 2012, loaded into one relational database. This site describes what was collected, how it was built and how it was checked.</p>
    <div class="actions"><a class="button button-primary" href="/data/">Explore the data <span aria-hidden="true">→</span></a><a class="button button-secondary" href="/pipeline/">How it was built</a></div>
  </div>
  <figure class="hero-figure"><div class="figure-header"><span>TWO-MODE NETWORK</span><span>01 / EDITORS × PAGES</span></div>
<svg class="hero-network" viewBox="0 0 450 370" role="img" aria-labelledby="network-title network-description">
<title id="network-title">Editors connected to the pages they edit</title><desc id="network-description">An illustrative network: editors on the left, pages on the right. One page is protected; two editors are excluded from it and keep editing other pages. Curves between editors are talk-page discussions. This is a schematic, not an empirical dataset.</desc>
<g class="halo" stroke-width="1.2"><path d="M70 110 C30 120 30 150 70 160"/><path d="M70 160 C25 175 25 195 70 210"/><path d="M70 110 C-5 140 -5 190 70 210"/></g>
<g class="edges" stroke-width="1.4"><line x1="70" y1="60" x2="361" y2="70"/>
<line x1="70" y1="60" x2="361" y2="150"/>
<line x1="70" y1="110" x2="361" y2="150"/>
<line x1="70" y1="110" x2="361" y2="70"/>
<line x1="70" y1="160" x2="361" y2="230"/>
<line x1="70" y1="210" x2="361" y2="230"/>
<line x1="70" y1="260" x2="361" y2="230"/>
<line x1="70" y1="260" x2="361" y2="310"/>
<line x1="70" y1="310" x2="361" y2="310"/>
<line x1="70" y1="310" x2="361" y2="230"/></g>
<g class="edges-excluded" stroke-width="1.4"><line x1="70" y1="160" x2="361" y2="150"/>
<line x1="70" y1="210" x2="361" y2="150"/></g>
<g><circle class="editor" cx="70" cy="60" r="7"/>
<circle class="editor" cx="70" cy="110" r="7"/>
<circle class="editor-excluded" cx="70" cy="160" r="7"/>
<circle class="editor-excluded" cx="70" cy="210" r="7"/>
<circle class="editor" cx="70" cy="260" r="7"/>
<circle class="editor" cx="70" cy="310" r="7"/></g>
<g><rect class="page" x="361" y="61" width="18" height="18"/>
<rect class="page-protected" x="361" y="141" width="18" height="18"/>
<rect class="page" x="361" y="221" width="18" height="18"/>
<rect class="page" x="361" y="301" width="18" height="18"/></g>
<g class="lock"><path d="M366 128 v-4 a4 4 0 0 1 8 0 v4"/><rect x="363" y="128" width="14" height="9"/></g>
<g font-size="9"><text x="40" y="34">EDITORS</text><text x="345" y="44">PAGES</text><text x="388" y="154">PROTECTED</text><text x="4" y="345">TALK</text></g></svg>
    <figcaption class="figure-caption"><span>Edit · request · protect · exclude</span><span>Illustrative network</span></figcaption>
  </figure>
</section>
<div class="fact-strip"><span><strong>1.25 B</strong> revisions with wikitext</span><span><strong>846,191</strong> protection-log events</span><span><strong>217,554</strong> protection requests</span><span><strong>14 TB</strong> in PostgreSQL 18</span></div>
<section class="home-section" aria-labelledby="layers-title">
  <div class="section-heading"><div><span class="kicker">From dumps to a research database</span><h2 id="layers-title">Three layers, one database</h2></div><a href="/pipeline/">See the full pipeline →</a></div>
  <div class="workflow-grid">
    <a class="workflow-card" href="/pipeline/#bulk_dumps"><span class="card-number">01 / BULK DUMPS</span><h3>The full edit history</h3><p>The April 2026 dumps from dumps.wikimedia.org: SQL tables, the administrative log, revision metadata and 1.25 billion revisions of wikitext, loaded in four phases.</p><span class="card-action">official-dump <span aria-hidden="true">→</span></span></a>
    <a class="workflow-card" href="/pipeline/#api_collections"><span class="card-number">02 / API COLLECTIONS</span><h3>Protection, as it happened</h3><p>Resumable MediaWiki API fetchers for the protection log and every monthly archive of Requests for page protection, granted and denied, with the deciding administrator.</p><span class="card-action">protection log · RFPP <span aria-hidden="true">→</span></span></a>
    <a class="workflow-card" href="/auditing/"><span class="card-number">03 / AUDIT</span><h3>What the database represents</h3><p>Coverage, provenance, joins and derived classifications, checked with reproducible read-only queries. Repairs are versioned, tested and reversible.</p><span class="card-action">db-auditing <span aria-hidden="true">→</span></span></a>
  </div>
</section>
<section class="home-section analysis-feature" aria-labelledby="query-title">
  <div><span class="kicker">Querying the snapshot</span><h2 id="query-title">One page.<br>Every edit, every editor.</h2><p>Relationship views join revisions to pages and editors without copying the dataset. Wikitext sits in its own partitioned table and is read only when a query asks for it.</p><a href="/data/#querying_the_database">See the tables and views →</a></div><div>
~~~

```sql
-- Revision -> page -> editor, through an index
SELECT rev_id, rev_timestamp,
       encode(page_title, 'escape') AS page_title,
       encode(actor_name, 'escape') AS editor
FROM wiki_relations.revision
WHERE rev_page = 13465879
ORDER BY rev_timestamp
LIMIT 20;
```

~~~
  </div>
</section>
<section class="home-section project-note" aria-label="About this project">
  <div><h3>Why page protection?</h3><p>Protection restricts who may edit a page, to curb vandalism, disputes and harm. It is also a constraint on participation. The project asks what protection does to the network of editors and pages around a protected page.</p><a href="/research/">Read the research design →</a></div>
  <div><h3>Built to be checked</h3><p>Requested protection, the administrator's decision and the protection actually applied are kept as separate measurements. Repaired labels record the version of the parser that produced them.</p><a href="/auditing/">See how the data are audited →</a></div>
</section>
</div>
~~~
