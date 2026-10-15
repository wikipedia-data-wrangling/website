@def title = "Pipeline"
@def hascode = true

# Pipeline

The database is built from two kinds of source. Bulk dumps from the Wikimedia Foundation give the complete edit history at one date. The MediaWiki API gives the protection record as administrators left it, including requests that were refused. Every step is resumable and can be re-run without duplicating data.

## Bulk dumps

The Wikimedia Foundation publishes [database dumps](https://dumps.wikimedia.org/enwiki/) of the English Wikipedia about twice a month. Several tables that used to be published as SQL are now only available as XML, so loading is split into four phases. The downloader verifies each file against the published SHA-1 checksums and skips files it already has.

| Phase | Source | Size | Tables populated |
| --- | --- | --- | --- |
| 1a | 7 SQL dumps | ~9 GB | `page`, `page_restrictions`, `protected_titles`, `user_groups`, `user_former_groups`, `change_tag`, `change_tag_def` |
| 1b | Logging XML, 27 parts | ~6.4 GB | `logging`, `actor` |
| 2 | Stub history XML, 27 files | ~225 GB | `revision`, `actor` |
| 3 | Full history XML, 956 `.7z` files | ~270 GiB compressed | `revision_text` |

```bash
./run_pipeline.sh phase1     # download and load 1a and 1b
./run_pipeline.sh phase2     # download and load revision metadata
./run_pipeline.sh freeze2    # pg_dump, key-figure snapshot, git tag
./run_pipeline.sh phase3     # download and load wikitext (several days)
./run_pipeline.sh freeze3    # snapshot, API spot check, git tag
```

Each loader empties its target table before loading, so a phase can be re-run safely. The exception is `actor`: logging and revision loads both add editor identities to it, and a re-run of one must not delete the identities the other created.

After each phase a freeze script dumps the database, records a set of key figures and their checksum, and tags the repository. Phase 3 finished on 3 July 2026.

## Storage

The wikitext alone is several terabytes, more than the machine's internal storage. `revision_text` is range-partitioned on `rev_id` at one billion. Older revisions sit on a large external disk, where they are rarely written. Newer revisions sit on an internal SSD, where random writes are about fifty times faster. Primary-key indexes live on NVMe, so a lookup by revision ID stays fast wherever the text is.

Foreign keys are not declared while loading. Bulk loads run faster without them, and the separately published dumps do not always agree. A post-load step builds the remaining indexes, validates the foreign keys the data support, and records the missing references for the ones they do not. It never edits or deletes rows.

## API collections

Two fetchers query the [MediaWiki API](https://en.wikipedia.org/w/api.php) and write JSON Lines. Both checkpoint after every batch, so an interrupted run resumes where it stopped. They identify themselves with a descriptive User-Agent, honour `maxlag`, and pause between calls, following the [API etiquette](https://www.mediawiki.org/wiki/API:Etiquette).

### Protection log

`fetch_protection_log.py` pages through `list=logevents&letype=protect` from oldest to newest. The full pull returned 846,191 actions, from log entry 4 (December 2004) to May 2026. Each record includes the protection level, expiry and cascade setting of the action.

### Requests for page protection

Editors ask for protection, or for its removal, at [Requests for page protection](https://en.wikipedia.org/wiki/Wikipedia:Requests_for_page_protection) (RFPP). Administrators answer each request on the page, and the requests are archived monthly. `fetch_rfpp.py` parses every archive from October 2012 to September 2026 into 217,554 requests. For each request it records:

- the page, the requester and the request text;
- the response, classified as granted, denied or other from the administrators' decision templates;
- the administrator who answered.

Refused requests and the identity of the deciding administrator are never dropped: they are central to the research design.

A first pull in May 2026 stopped at 82,412 requests. An API response-size cap had silently truncated large archive pages. The fetcher was fixed and the whole population pulled again in September 2026.

## Linking the sources

Requests are resolved against the dump: page titles to `page_id`, user names to actor identifiers. Each request is then matched to the protection actions that followed it in the log. From the log, protection events are parsed and assembled into *episodes*: periods from the moment a protection is applied until it expires or is lifted. All of this is written to the `analysis` schema by numbered, idempotent SQL scripts.

## Code

- [official-dump](https://github.com/wikipedia-data-wrangling/official-dump): downloader, the four loaders, schema, storage layout and the post-load relationship layer.
- fetch-protection-events: the protection-log and RFPP fetchers. This repository is private.
- [db-auditing](https://github.com/wikipedia-data-wrangling/db-auditing): audits of the loaded and derived data.
