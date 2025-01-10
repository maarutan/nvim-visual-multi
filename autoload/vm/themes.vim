let s:Themes = {}
let s:Themes._light = ['auto_light', 'catppuccin_latte']
let s:Themes._dark = ['auto_dark', 'catppuccin_mocha']

" Хелпер для применения цветовых схем
fun! s:ApplyHighlights(highlights) abort
  for [group, attrs] in a:highlights
    execute 'hi! ' . group . ' ' . join(attrs, ' ')
  endfor
endfun

" Тема auto_dark
fun! s:Themes.auto_dark() abort
  call s:ApplyHighlights([
        \ ['VM_Extend', ['ctermbg=24', 'guibg=#45475B']],
        \ ['VM_Cursor', ['ctermbg=15', 'ctermfg=0', 'guibg=#CDD6F5', 'guifg=#262626']],
        \ ['VM_Insert', ['ctermbg=239', 'guibg=#CDD6F5', 'guifg=#262626']],
        \ ['VM_Mono',   ['ctermbg=180', 'ctermfg=235', 'guibg=#dadada', 'guifg=#262626']]
        \ ])
endfun

" Тема auto_light
fun! s:Themes.auto_light() abort
  call s:ApplyHighlights([
        \ ['VM_Extend', ['ctermbg=24', 'guibg=#BCC0CD']],
        \ ['VM_Cursor', ['ctermbg=15', 'ctermfg=0', 'guibg=#4C4F6A', 'guifg=#CDD6F5']],
        \ ['VM_Insert', ['ctermbg=239', 'guibg=#4C4F6A', 'guifg=#CDD6F5']],
        \ ['VM_Mono',   ['ctermbg=180', 'ctermfg=235', 'guibg=#4C4F6A', 'guifg=#CDD6F5']]
        \ ])
endfun

" Тема catppuccin_mocha
fun! s:Themes.catppuccin_mocha() abort
  call s:ApplyHighlights([
        \ ['VM_Extend', ['ctermbg=25', 'guibg=#4C4F6A']],
        \ ['VM_Cursor', ['ctermbg=39', 'ctermfg=239', 'guibg=#89B4FB', 'guifg=#1E1E2F']],
        \ ['VM_Insert', ['ctermbg=239', 'ctermfg=239', 'guibg=#A6E3A2', 'guifg=#1E1E2F']],
        \ ['VM_Mono',   ['ctermbg=186', 'ctermfg=239', 'guibg=#CDD6F5', 'guifg=#1E1E2F']]
        \ ])
endfun

" Тема catppuccin_latte
fun! s:Themes.catppuccin_latte() abort
  call s:ApplyHighlights([
        \ ['VM_Extend', ['ctermbg=25', 'guibg=#BCC0CD']],
        \ ['VM_Cursor', ['ctermbg=39', 'ctermfg=239', 'guibg=#1E66F6', 'guifg=#EFF1F6']],
        \ ['VM_Insert', ['ctermbg=239', 'ctermfg=239', 'guibg=#40A02C', 'guifg=#EFF1F6']],
        \ ['VM_Mono',   ['ctermbg=186', 'ctermfg=239', 'guibg=#4C4F6A', 'guifg=#EFF1F6']]
        \ ])
endfun
