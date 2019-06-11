if !exists("g:ghcid_cmd")
    let g:ghcid_cmd = "ghcid"
endif

if !exists("g:ghcid_open_on_error")
    let g:ghcid_open_on_error = 1
endif



function! ghcid#start(args) abort
    if !executable(g:ghcid_cmd)
        echomsg g:ghcid_cmd . " not found"
        return
    endif

    call s:clear_quickfix()
    let quickfix_buffer = s:quickfix_buffer()
    let output_buffer = s:scratch_buffer()
    let cmd = g:ghcid_cmd . ' --color=never'

    call term_start(cmd, {
        \ 'out_io':  'buffer',      'err_io':  'buffer',
        \ 'out_buf': output_buffer, 'err_buf': output_buffer,
        \ 'term_kill': 'term',
        \ 'hidden': v:true,
        \ 'term_name': 'ghcid',
        \ 'out_cb': function('s:ghcid_output_handler', [quickfix_buffer]),
        \ 'err_cb': function('s:ghcid_output_handler', [quickfix_buffer]),
        \ })
endfunction

function! s:ghcid_output_handler(quickfix_buffer, channel, msg) abort
    for rawline in split(a:msg, "[\r\n]")
        let line = s:clean(rawline)

        if match(line, '^Reloading...') isnot -1
            call s:clear_quickfix()

        elseif match(line, '^All good') isnot -1
            cclose
            echo 'All good'

        elseif match(line, 'error') isnot -1
            if g:ghcid_open_on_error == 1
                copen
                wincmd p
            endif

        endif

    caddexpr line
    endfor
endfunction

function! s:clear_quickfix()
    call setqflist([])
endfunction

function! s:clean(line)
    return substitute(a:line, '\[^/\p\]', '', 'g')
endfunction

function! s:quickfix_buffer() abort
  copen
  return winbufnr('.')
endfunction

function! s:scratch_buffer() abort
  new
  file 'ghcid_output_buffer'
  setl buftype=nofile
  setl nobuflisted
  let buffer = winbufnr('.')
  quit
  return buffer
endfunction
