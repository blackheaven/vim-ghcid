command! -bar -nargs=* GhcidStart call ghcid#start(<q-args>)
command! GhcidStop  call ghcid#stop()
