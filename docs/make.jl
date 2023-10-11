using Faux
using Documenter

DocMeta.setdocmeta!(Faux, :DocTestSetup, :(using Faux); recursive=true)

makedocs(;
    modules=[Faux],
    authors="debruine <debruine@gmail.com> and contributors",
    repo="https://github.com/debruine/Faux.jl/blob/{commit}{path}#{line}",
    sitename="Faux.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://debruine.github.io/Faux.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/debruine/Faux.jl",
    devbranch="main",
)
