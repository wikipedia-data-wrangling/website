function hfun_canonical_url()
    return replace(locvar("fd_full_url"), r"/index\.html$" => "/")
end
