"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set up highlighting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:Themes = {}

augroup VM_reset_theme
  au!
  " Инициализация темы при смене `background`
  au OptionSet background call vm#themes#apply_background()
  au ColorScheme * call vm#themes#init()
augroup END

function! vm#themes#apply_background() abort
  " Автоматический выбор темы на основе значения `background`
  if &background == 'dark'
    call vm#themes#load('auto')
  elseif &background == 'light'
    call vm#themes#load('autolight')
  endif
endfunction

function! vm#themes#init() abort
  if !exists('g:Vm')
    let g:Vm = {}
    " Удалено `return`, чтобы продолжить выполнение функции
  endif

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
endfunction

function! vm#themes#load(theme) abort
  " Load a theme or set default.
  if empty(a:theme) || a:theme == 'default'
    let g:VM_theme = 'default'
  elseif index(keys(s:Themes), a:theme) < 0
    echo "No such theme."
    return
  else
    let g:VM_theme = a:theme
  endif
  call vm#themes#init()
endfunction

function! vm#themes#search_highlight() abort
  " Init Search highlight.
  let hl = g:VM_highlight_matches
  let g:Vm.Search = hl == 'underline' ? 'Search term=underline cterm=underline gui=underline' :
        \           hl == 'red'       ? 'Search ctermfg=196 guifg=#89B4FB' :
        \           hl =~ '^hi!\? '   ? substitute(g:VM_highlight_matches, '^hi!\?', '', '')
        \                             : 'Search term=underline cterm=underline gui=underline'
endfunction

function! vm#themes#complete(A, L, P) abort
  let valid = &background == 'light' ? s:Themes._light : s:Themes._dark
  return filter(sort(copy(valid)), 'v:val=~#a:A')
endfunction

function! vm#themes#statusline() abort
  if !exists('b:VM_Selection') || !exists('b:VM_Selection.Vars')
    return ''
  endif

  try
    let v = b:VM_Selection.Vars
    let vm = VMInfos()
    let color  = '%#VM_Extend#'
    let single = v.single_region ? '%#VM_Mono# SINGLE ' : ''

    if v.insert
      if v.insert.replace
        let [mode, color] = ['V-R', '%#VM_Mono#']
      else
        let [mode, color] = ['V-I', '%#VM_Cursor#']
      endif
    else
      let mode_map = {'n': 'V-M', 'v': 'V', 'V': 'V-L', "\<C-v>": 'V-B'}
      let mode = get(mode_map, mode(), 'V-M')
    endif

    let mode = exists('v:statusline_mode') ? v:statusline_mode : mode
    let patterns = string(vm.patterns)[:(winwidth(0) - 30)]
    return printf("%s %s %s %s %s%s %s %%=%%l:%%c %s %s",
          \ color, mode, '%#VM_Insert#', vm.ratio, single, '%#TabLine#',
          \ patterns, color, vm.status . ' ')
  catch
    return 'VM Statusline Error'
  endtry
endfunction

function! VMInfos() abort
  return {'patterns': 'example', 'ratio': '100%', 'status': 'Active'}
endfunction

let s:Themes._light = ['auto_light', "catppuccin_latte", "gruvbox_day" ]
let s:Themes._dark = ['auto_dark', "catppuccin_mocha", "gruvbox" ]



 """""" auto theme """"""
fun! s:Themes.auto_dark() abort
  hi! VM_Extend ctermbg=24                   guibg=#45475B
  hi! VM_Cursor ctermbg=15    ctermfg=0      guibg=#CDD6F5   guifg=#262626
  hi! VM_Insert ctermbg=239                  guibg=#CDD6F5   guifg=#262626
  hi! VM_Mono   ctermbg=180   ctermfg=235    guibg=#dadada   guifg=#262626
endfun
fun! s:Themes.auto_light() abort
  hi! VM_Extend ctermbg=24                   guibg=#BCC0CD
  hi! VM_Cursor ctermbg=15    ctermfg=0      guibg=#4C4F6A    guifg=#CDD6F5
  hi! VM_Insert ctermbg=239                  guibg=#4C4F6A    guifg=#CDD6F5
  hi! VM_Mono   ctermbg=180   ctermfg=235    guibg=#4C4F6A    guifg=#CDD6F5
endfun




 """""" catppuccin theme """"""
fun! s:Themes.catppuccin_mocha()
  hi! VM_Extend ctermbg=25                   guibg=#4C4F6A
  hi! VM_Cursor ctermbg=39    ctermfg=239    guibg=#89B4FB    guifg=#1E1E2F
  hi! VM_Insert ctermbg=239   ctermfg=239    guibg=#A6E3A2    guifg=#1E1E2F
  hi! VM_Mono   ctermbg=186   ctermfg=239    guibg=#CDD6F5    guifg=#1E1E2F
endfun
fun! s:Themes.catppuccin_latte()
  hi! VM_Extend ctermbg=25                   guibg=#BCC0CD
  hi! VM_Cursor ctermbg=39    ctermfg=239    guibg=#1E66F6    guifg=#EFF1F6
  hi! VM_Insert ctermbg=239   ctermfg=239    guibg=#40A02C    guifg=#EFF1F6
  hi! VM_Mono   ctermbg=186   ctermfg=239    guibg=#4C4F6A    guifg=#EFF1F6
endfun



 """""" gruvbox theme """"""
 fun! s:Themes.gruvbox()
  hi! VM_Extend ctermbg=25                   guibg=#458588
  hi! VM_Cursor ctermbg=39    ctermfg=239    guibg=#83a598    guifg=#3c3836
  hi! VM_Insert ctermbg=239   ctermfg=239    guibg=#3c3836    guifg=#3c3836
  hi! VM_Mono   ctermbg=186   ctermfg=239    guibg=#d79921    guifg=#3c3836
endfun
fun! s:Themes.gruvbox_day()
  hi! VM_Extend ctermbg=25                   guibg=#d5c4a1
  hi! VM_Cursor ctermbg=39    ctermfg=239    guibg=#a89984    guifg=#3c3836
  hi! VM_Insert ctermbg=239   ctermfg=239    guibg=#f2e5bc    guifg=#3c3836
  hi! VM_Mono   ctermbg=186   ctermfg=239    guibg=#fabd2f    guifg=#3c3836
endfun

