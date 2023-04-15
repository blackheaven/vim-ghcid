# vim-ghcid

Integrates with [ghcid](https://github.com/ndmitchell/ghcid) in the background
so it loads errors and warnings in the quickfix window every time you save your
code, and does it fast.

Inspired by aiya000's version.

## Installation

Compatible with `Vundle`, `Pathogen`, `Vim-plug`, etc.


## Usage

Start Ghcid with `:GhcidStart [ghcid args]`. Stop it with `:GhcidStop`

Example with `[ghcid args]`:

```
:GhcidStart --warnings --test testModule.test
```

## Configuration

Configure the *ghcid* command to use. Useful if it's outside your *PATH*
(default = "ghcid"):

```vim
let g:ghcid_cmd = "ghcid"
```

Show all of ghcid's output in the quickfix window (default = 0):

```vim
let g:ghcid_verbose = 0
```

Automatically open the quickfix window when there are errors (default = 1):

```vim
let g:ghcid_open_on_error = 1
```

Automatically open the quickfix window when there are warnings (default = 0):

```vim
let g:ghcid_open_on_warning = 0
```
