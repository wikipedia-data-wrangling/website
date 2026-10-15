@def title = "The data"
@def hascode = true

# The data

The database `wiki20260401` holds the English Wikipedia as published in the dump of 1 April 2026, together with two collections pulled from the MediaWiki API and a schema of derived tables built for analysis. It runs on PostgreSQL 18 and occupies about 14 TB.

~~~<div class="notice">~~~
**Dates differ by source.** The April 2026 dump date is not the observation date of every record, nor the coverage boundary of every source. The protection log was pulled on 6 May 2026 and the protection requests on 30 September 2026. Each table records where its rows came from.
~~~</div>~~~

## Sources

| Source | Collected | Contents |
| --- | --- | --- |
| SQL dumps (`*.sql.gz`) | dump of 2026-04-01 | Pages, current protection settings, protected titles, user groups, change tags |
| Logging XML | dump of 2026-04-01 | The administrative log: protections, blocks, rights changes, moves, deletions |
| Stub history XML | dump of 2026-04-01 | Metadata of every revision: page, editor, timestamp, size, parent |
| Full history XML (`.7z`) | dump of 2026-04-01 | The wikitext of every revision |
| Protection log (API) | 2026-05-06 | 846,191 protection actions, from the first log entry in December 2004 |
| Requests for page protection (API) | 2026-09-30 | 217,554 requests from every monthly archive, October 2012 to September 2026 |

Namespaces are not filtered at load time. Articles, talk pages, user pages and project pages are all present; queries select the namespaces they need (`page_namespace = 0` for articles, odd namespaces for talk pages).

## Base tables

The base tables keep the MediaWiki schema, so documentation for MediaWiki's own tables applies to them. Row counts are planner estimates.

| Table | Rows | What a row is |
| --- | ---: | --- |
| `revision` | 1.25 B | One edit to one page |
| `revision_text` | 1.25 B | The wikitext of one revision, in two range partitions on `rev_id` |
| `change_tag` | 546 M | A tag attached to a revision or log entry |
| `logging` | 158 M | One administrative action |
| `actor` | 111 M | An editor identity: a registered account or an IP address |
| `page` | 65 M | A page that exists at the dump date |
| `page_restrictions` | 193 k | A protection setting in force at the dump date |
| `user_groups` | 103 k | A current user-group membership, such as administrator |
| `protected_titles` | 59 k | Creation protection on a title that has no page |
| `user_former_groups` | 22 k | A group an account used to belong to |
| `change_tag_def` | 335 | The name of a change tag |

`revision_text` has slightly fewer rows than `revision`: revisions whose text was deleted or suppressed carry metadata but no wikitext.

## Protection data

Protection appears in several tables, and each measures something different. Requested protection, the administrator's decision and the protection actually applied are kept apart. Disagreement between them can be informative, so one is never copied into another.

| Object | What it represents |
| --- | --- |
| `page_restrictions` | Protection settings on existing pages at the dump date |
| `protected_titles` | Creation protection for titles with no page |
| `logging` | Historical administrative actions, including protection actions |
| `analysis.protect_event` | Parsed protection events and their reconstructed parameters |
| `analysis.protection_episode` | Reconstructed periods during which a page was protected |
| `analysis.rfpp_request` | Protection requests: the protection asked for, the response, the deciding administrator, and the matched log action |

## Derived tables

Derived tables live in a separate `analysis` schema; the base tables in `public` are never modified. The main ones:

| Table | Rows | Contents |
| --- | ---: | --- |
| `protect_event` | 1.1 M | Each protection action with its level, expiry and cascade parameters |
| `protection_episode` | 1.0 M | Protection periods per page, from application to expiry or removal |
| `rfpp_request` | 218 k | Protection requests resolved to page and actor identifiers, with parsed intent and outcome |
| `editor_history` | 35 M | Per-editor histories used to decide who could edit a page at a given time |
| `block_interval` | 28 M | Periods during which an account or address was blocked |
| `user_registration` | 52 M | Account registration dates |
| `page_quality` | 52 k | Article-quality predictions for the analysed pages |

## Querying the database

Seven views in the `wiki_relations` schema connect the base tables without copying them. They use left joins, so unmatched rows are kept, and `*_found` flags mark references whose target is missing, for example a revision of a page deleted before the dump.

```sql
-- Tags, their names, and the revision or log entry they belong to
SELECT ct_id, ctd_name, rev_page, revision_found, log_found
FROM wiki_relations.change_tag
WHERE ct_rev_id = 1000000000;

-- Wikitext by revision ID; metadata queries never touch it
SELECT r.rev_id, r.rev_timestamp, t.rev_text
FROM wiki_relations.revision r
LEFT JOIN public.revision_text t USING (rev_id)
WHERE r.rev_id = 1000000000;
```

Two identities are easy to confuse. An *actor* is any editing identity, including IP addresses; a *user* is a registered account. Group memberships refer to user IDs, which are not unique in `actor`, so a join from groups to actors can return several rows for one account.

## Licensing

Wikipedia text is dual-licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and the [GFDL](https://www.gnu.org/licenses/fdl-1.3.html); attribution and share-alike apply to any redistribution. The database is rebuilt from the public dumps and the API by the code in the [project repositories](https://github.com/wikipedia-data-wrangling) rather than redistributed.
