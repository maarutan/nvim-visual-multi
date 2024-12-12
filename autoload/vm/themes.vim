""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Set up highlighting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:Themes = {}

augroup VM_reset_theme
  au!
  au ColorScheme * call vm#themes#init()
augroup END

fun! vm#themes#init() abort
  if !exists('g:Vm') | return | endif

  if !empty(g:VM_highlight_matches)
    let out = execute('highlight Search')
    if match(out, ' links to ') >= 0
      let hi = substitute(out, '^.*links to ', '', '')
      let g:Vm.search_hi = "link Search " . hi
    else
      let hi = strtrans(substitute(out, '^.*xxx ', '', ''))
      let hi = substitute(hi, '\^.', '', 'g')
      let g:Vm.search_hi = "Search " . hi
    endif

    call vm#themes#search_highlight()
  endif

  let theme = get(g:, 'VM_theme', '')

  if theme == 'default'
    hi! link VM_Mono ErrorMsg
    hi! link VM_Cursor Visual
    hi! link VM_Extend PmenuSel
    hi! link VM_Insert DiffChange
    hi! link MultiCursor VM_Cursor

  elseif has_key(s:Themes, theme)
    call s:Themes[theme]()
  endif
endfun

fun! vm#themes#search_highlight() abort
  let hl = g:VM_highlight_matches
  let g:Vm.Search = hl == 'underline' ? 'Search term=underline cterm=underline gui=underline' :
        \           hl == 'red'       ? 'Search ctermfg=196 guifg=#ff0000' :
        \           hl =~ '^hi!\? '   ? substitute(g:VM_highlight_matches, '^hi!\?', '', '') :
        \                             'Search term=underline cterm=underline gui=underline'
endfun

fun! vm#themes#load(theme) abort
  if empty(a:theme) || a:theme == 'default'
    let g:VM_theme = 'default'
  elseif !has_key(s:Themes, a:theme)
    call vm#themes#add_theme_from_lua(a:theme)
  endif
  if has_key(s:Themes, a:theme)
    call s:Themes[a:theme]()
    echo "Theme '" . a:theme . "' loaded."
  else
    echo "Theme '" . a:theme . "' not found."
  endif
endfun

fun! vm#themes#add_theme_from_lua(name) abort
  if has_key(s:Themes, a:name)
    echo "Theme '" . a:name . "' already exists."
    return
  endif
  try
    let s:Themes[a:name] = function('luaeval', 'require("vm_themes").get_theme("' . a:name . '")')
    echo "Theme '" . a:name . "' added successfully from Lua."
  catch /^Vim\%((\a\+)\)\=:E/
    echo "Error loading theme '" . a:name . "' from Lua."
  endtry
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Existing themes
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" (Текущий список тем остаётся без изменений)

" vim: et ts=2 sw=2 sts=2 :
