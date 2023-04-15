if !exists("g:ghcid_cmd")
    let g:ghcid_cmd = "ghcid"
endif

if !exists("g:ghcid_open_on_error")
    let g:ghcid_open_on_error = 1
endif

if !exists("g:ghcid_open_on_warning")
    let g:ghcid_open_on_warning = 0
endif

if !exists("g:ghcid_verbose")
    let g:ghcid_verbose = 0
endif


let s:ghcid_running = 0
let s:error_count = 0
let s:warning_count = 0

function! ghcid#stop()
    if s:ghcid_running isnot 0
        let buffer = bufnr('ghcid')
        call term_setkill(buffer, 'term')
        exe 'bdel! ' . buffer
        cclose
        let s:ghcid_running = 0
        echomsg "Ghcid stopped"
    endif
endfunction

function! ghcid#start(ghcid_args = "") abort
    if s:ghcid_running isnot 0
        echomsg "Ghcid is already running"
        return
    endif

    if !executable(g:ghcid_cmd)
        echomsg g:ghcid_cmd . " not found"
        return
    endif

    call s:clear_quickfix()
    let quickfix_buffer = s:quickfix_buffer()
    let output_buffer = s:scratch_buffer()
    let cmd = g:ghcid_cmd . ' --color=never ' . a:ghcid_args
    echomsg "Starting ghcid " . a:ghcid_args

    call term_start(cmd, {
        \ 'out_io':  'buffer',
        \ 'out_buf': output_buffer,
        \ 'term_kill': 'term',
        \ 'hidden': v:true,
        \ 'term_name': 'ghcid',
        \ 'out_cb': function('s:ghcid_output_handler', [quickfix_buffer]),
        \ })

    let s:ghcid_running = 1
endfunction

let s:reading_garbage = 1
function! s:ghcid_output_handler(quickfix_buffer, channel, msg) abort
    for rawline in split(a:msg, "[\r\n]")
        let line = s:clean(rawline)

        if match(line, '^Reloading...') isnot -1
            echo "Reloading..."
            call s:clear_quickfix()
            let s:error_count = 0
            let s:warning_count = 0
            let s:reading_garbage = 1
            continue

        elseif match(line, '^All good') isnot -1
            cclose
            echo line
            continue

        elseif match(line, ' error:') isnot -1
            let s:error_count +=1
            let s:reading_garbage = 0

        elseif match(line, ' warning:') isnot -1
            let s:warning_count +=1
            let s:reading_garbage = 0

        endif

        if g:ghcid_verbose is 1 || s:reading_garbage isnot 1
            caddexpr line
        endif

    endfor


    if s:error_count > 0
        echo "Compiler errors: " . s:error_count
        if g:ghcid_open_on_error == 1
            copen
            wincmd p
        endif
    endif

    if s:error_count == 0 && s:warning_count > 0
        echo "Compiled with " . s:warning_count . " warnings"
        if g:ghcid_open_on_warning == 1
            copen
            wincmd p
        endif
    endif

endfunction

function! s:clear_quickfix()
    call setqflist([])
endfunction

function! s:clean(line)
    let garbage = [
        \ '\[^/\p\]',
        \ '',
        \ '',
        \ '',
        \ '\e]\d',
        \ '\e[\(\d\+\)\?\(;\d\+\)*m',
        \ '\e[m',
        \ '\]\(\d\+\)\?\(;\d\+\)*',
        \ ]
    let remove = '\(' . join(garbage, '\|') . '\)'
    let mostly_clean =  substitute(a:line, remove, '', 'g')
    return substitute(mostly_clean, '^;', ' ', 'g')
endfunction

function! s:quickfix_buffer() abort
  copen
  let buffer = winbufnr('.')
  cclose
  return buffer
endfunction

function! s:scratch_buffer() abort
  new
  exe 'sil! file "ghcid_output_buffer"'
  setl buftype=nofile
  setl nobuflisted
  let buffer = winbufnr('.')
  quit
  return buffer
endfunction
