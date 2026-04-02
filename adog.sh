function adog {
    #local flags='--decorate --oneline --graph --abbrev=4 --date=human'
    local flags=(
        --graph
        --decorate
        --abbrev=4
        '--format=format:%C(auto)%h %C(bold blue)%an%C(reset) %s %C(dim white)%ad%C(reset) %C(auto)%d'
        --date=human
    )
    if [[ $# -eq 0 ]] ; then
        git log "${flags[@]}" --all
    else
        git log "${flags[@]}" $@
    fi
}
adog $@
