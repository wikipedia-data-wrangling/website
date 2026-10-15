# website

A simple website showcasing the project: the English Wikipedia's edit history
and protection record as a research database. Published at
<https://wikipedia-data-wrangling.github.io/website/>.

Built with [Franklin.jl](https://franklinjl.org/); the layout follows the
[Statistical analysis of networks in Julia](https://github.com/statistical-network-analysis-with-Julia/statistical-network-analysis-with-Julia.github.io)
site, recoloured with Wikipedia's interface palette (Wikimedia Codex tokens,
light and dark).

## Preview locally

```sh
julia --project -e 'using Pkg; Pkg.instantiate(); using Franklin; serve()'
```

`serve()` previews at the site root; the deployed build adds the
`/website` prefix (`prepath` in `config.md`).

## Publishing

Every push to `main` runs `.github/workflows/deploy.yml`, which builds the
site with `optimize()` and deploys `__site/` to GitHub Pages. Pull requests
build without deploying.

## Layout

- `index.md`, `data/`, `pipeline/`, `auditing/`, `research/`: pages
- `_layout/`: header, footer and navigation partials
- `_css/style.css`: styles; colour tokens at the top
- `_assets/`: `site.js` (menu, section highlighting, copy buttons), JuliaMono, logo
