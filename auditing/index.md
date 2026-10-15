@def title = "Auditing"

# Auditing

A query that runs does not show that its classification, linkage or interpretation is valid. The [db-auditing](https://github.com/wikipedia-data-wrangling/db-auditing) repository checks what the database actually represents, which questions it can support, and where it needs correction or more evidence.

## What is assessed

- **Coverage and provenance.** Source files, collection dates, namespace and time coverage, which records were kept or excluded, and differences between the live database and exported copies.
- **Schema and relationships.** Identifiers, primary and foreign keys, missing references, user versus actor identity, page moves and deletions, and whether joins preserve the intended unit of observation.
- **Ingestion and storage.** Agreement between SQL, XML and API sources, byte-preserving types and encodings, timestamps, partitioning and indexes.
- **Derived classifications.** Request intent, administrative outcomes, applied protection levels, protection episodes, missing values and ambiguous cases, and the evidence behind each parsing and matching rule.
- **Consequences for analysis.** Sample selection, request-to-log matches, eligibility rules, comparison groups, and how a correction propagates into exports and results.

## How an audit works

Each audit states its question and the design choice it examines. It inspects the implementation, reproduces the finding with bounded read-only queries, and separates confirmed defects from candidate cases and open assumptions. The record includes the database and source versions, the exact population filters, stable identifiers, the queries and their results, and the limitations.

A repair needs a reproducible test corpus and a record of every value it changed. The previous version of each table is preserved so that the change can be reviewed and reversed. Downstream tables and exports that depend on the repaired data are listed for rebuilding. An audit is not complete because a symptom disappears.

## October 2026 panel audit

On 11 October 2026 four specialist reviews examined the database from different angles: software engineering, PostgreSQL, computational social science and Wikipedia's own conventions. The audit made no changes to the data. It produced measured findings, the read-only queries that reproduce them, a prioritised action register and fifteen [GitHub issues](https://github.com/wikipedia-data-wrangling/db-auditing/issues).

## Repairing request intent

The [first issue](https://github.com/wikipedia-data-wrangling/db-auditing/issues/1) concerned what each protection request asked for. The parser read duration phrases as requests for extended-confirmed protection, and read explicit requests to lower protection as requests to raise it.

The repair, parser version `rfpp-intent-v2.1.0`, re-derived the intent of all 217,554 requests. It fixed the direction of requested changes, removal targets, nested request headings and requests stated in the body of the text. Requests that mix several operations stay unresolved. The repair shipped with:

- regression tests on semantic and historical fixtures;
- confusion tables comparing old and new labels, and the identities of every changed request;
- the parser version stored with each label;
- the previous database tables and exports preserved, and a rollback script.
