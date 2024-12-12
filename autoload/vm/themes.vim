let s:Themes = {}

" Регистрация темы из Lua
fun! vm#themes#add_theme_from_lua(name) abort
  if has_key(s:Themes, a:name)
    echo "Theme '" . a:name . "' already exists."
    return
  endif
  try
    let s:Themes[a:name] = function('luaeval', 'require("vm_themes").get_theme("' . a:name . '")')
    echo "Theme '" . a:name . "' added successfully from Lua."
  catch /^Vim\%((\a\+)\)\=:E/
    echo "Failed to load theme '" . a:name . "' from Lua. Ensure it is defined in `vm_themes`."
  endtry
endfun

" Загрузка темы
fun! vm#themes#load_theme(theme) abort
  if !has_key(s:Themes, a:theme)
    call vm#themes#add_theme_from_lua(a:theme)
  endif
  if has_key(s:Themes, a:theme)
    call s:Themes[a:theme]()
    echo "Theme '" . a:theme . "' loaded."
  else
    echo "Theme '" . a:theme . "' not found."
  endif
endfun

" Автоматическая загрузка темы
if exists('g:VM_theme')
  call vm#themes#load_theme(g:VM_theme)
endif
