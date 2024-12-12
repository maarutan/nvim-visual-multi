""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File:         visual-multi.vim
" Description:  multiple selections in vim
" Mantainer:    Gianmaria Bajo <mg1979.git@gmail.com>
" Url:          https://github.com/mg979/vim-visual-multi
" Licence:      The MIT License (MIT)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Guard {{{
if v:version < 800
  echomsg '[vim-visual-multi] Vim version 8 is required'
  finish
endif

if exists("g:loaded_visual_multi")
  finish
endif
let g:loaded_visual_multi = 1

let s:save_cpo = &cpo
set cpo&vim
"}}}

com! -nargs=? -complete=customlist,vm#themes#complete VMTheme call vm#themes#load(<q-args>)

com! -bar VMDebug  call vm#special#commands#debug()
com! -bar VMClear  call vm#hard_reset()
com! -bar VMLive   call vm#special#commands#live()

com! -bang  -nargs=?       VMRegisters call vm#special#commands#show_registers(<bang>0, <q-args>)
com! -range -bang -nargs=? VMSearch    call vm#special#commands#search(<bang>0, <line1>, <line2>, <q-args>)

" Deprecated commands {{{1
com! -bang VMFromSearch call vm#special#commands#deprecated('VMFromSearch')
"}}}

hi default link VM_Mono IncSearch
hi default link VM_Cursor Visual
hi default link VM_Extend PmenuSel
hi default link VM_Insert DiffChange
hi link MultiCursor VM_Cursor

if exists('g:VM_theme')
  call vm#themes#load(g:VM_theme)
endif

let g:Vm = { 'hi'          : {},
      \ 'buffer'           : 0,
      \ 'extend_mode'      : 0,
      \ 'finding'          : 0,
      \ 'mappings_enabled' : 0,
      \ 'last_ex'          : '',
      \ 'last_normal'      : '',
      \ 'last_visual'      : '',
      \ 'registers'        : {'"': [], '-': []},
      \ 'oldupdate'        : exists("##TextYankPost") ? 0 : &updatetime,
      \}

let g:VM_highlight_matches = get(g:, 'VM_highlight_matches', 'underline')

call vm#plugs#permanent()
call vm#maps#default()

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ft=vim et sw=2 ts=2 sts=2 fdm=marker
