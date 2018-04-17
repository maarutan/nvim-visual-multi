let s:motion = '' | let s:starting_col = 0
let s:merge = 0  | let s:dir = 0
let s:X = { -> g:VM.extend_mode }

fun! s:init(whole, cursor, extend_mode)
    if a:extend_mode | let g:VM.extend_mode = 1 | endif

    "return if already initialized
    if g:VM.is_active | return 1 | endif

    if g:VM_motions_at_start | call vm#maps#motions(1) | endif

    let s:V       = vm#init_buffer(a:cursor)
    let s:v       = s:V.Vars
    let s:Regions = s:V.Regions
    let s:Global  = s:V.Global
    let s:Funcs   = s:V.Funcs
    let s:Search  = s:V.Search
    let s:Edit    = s:V.Edit

    let s:v.whole_word = a:whole
    let s:v.nav_direction = 1
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Change mode
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#change_mode(silent)
    let g:VM.extend_mode = !s:X()
    let s:v.silence = a:silent

    if s:X()
        call s:Funcs.msg('Switched to Extend Mode')
        call s:Global.update_regions()
    else
        call s:Funcs.msg('Switched to Cursor Mode')
        call s:Global.collapse_regions()
    endif
    call s:Funcs.count_msg(0)
endfun


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Add cursor
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:check_extend_default(X)
    """If just starting, enable extend mode if option is set."""

    if s:X()                                 | return s:init(0, 1, 1)
    elseif ( a:X || g:VM_extend_by_default ) | return s:init(0, 1, 1)
    else                                     | return s:init(0, 1, 0) | endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#add_cursor_at_word(yank, search)
    call s:init(0, 1, 0)

    if a:yank   | call s:yank(0)      | exe "keepjumps normal! `[" | endif
    if a:search | call s:Search.add() | endif

    call s:Global.new_cursor()
    call s:Funcs.count_msg(1)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#add_cursor_at_pos(where, extend, ...)
    call s:check_extend_default(a:extend)
    if a:where && !s:starting_col | let s:starting_col = col('.') | endif

    "silently add one cursor at pos
    if !a:0 | call s:Global.new_cursor() | endif

    if a:where == 1
        keepjumps normal! j
        let R = s:Global.new_cursor()
    elseif a:where == 2
        keepjumps normal! k
        let R = s:Global.new_cursor()
    endif

    "when adding cursors below or above, don't add on empty lines
    if g:VM_cursors_skip_shorter_lines && a:where
        if R.a < s:starting_col || R.a == len(getline('.')) + 1
            call R.remove()
            call vm#commands#add_cursor_at_pos(a:where, 0, 1) | return
        endif | endif
    let s:starting_col = 0
    call s:Funcs.count_msg(0)
endfun


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Find by regex
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#regex_reset(...)
    silent! cunmap <buffer> <cr>
    silent! cunmap <buffer> <esc>
    if a:0 | return a:1 | endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#regex_abort()
    let @/ = s:regex_reg
    call s:Funcs.msg('Regex search aborted.') | call s:Funcs.count_msg(1)
    call setpos('.', s:regex_pos)
    call vm#commands#regex_reset()
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#regex_done()
    call vm#commands#regex_reset()

    silent keepjumps normal! gny`]
    call s:Search.get_slash_reg()

    if s:X()      | call s:Global.get_region() | call s:Funcs.count_msg(0)
    else          | call vm#commands#add_cursor_at_word(0, 0)
    endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#find_by_regex(...)
    if !g:VM.is_active | call vm#commands#regex_reset() | return | endif

    "store reg and position, to check if the search will be aborted
    let s:regex_pos = getpos('.')
    let s:regex_reg = @/

    cnoremap <silent> <buffer> <cr> <cr>:call vm#commands#regex_done()<cr>
    cnoremap <buffer> <esc> <cr>:call vm#commands#regex_abort()<cr>
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Find under commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NOTE: don't call s:Funcs.count_msg() after merging regions, or it will be
" called twice.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:yank(inclusive)
    if a:inclusive | silent keepjumps normal! yiW`]
    else           | silent keepjumps normal! yiw`]
    endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#find_under(visual, whole, inclusive)
    call s:init(a:whole, 0, 1)

    " yank and create region
    if !a:visual | call s:yank(a:inclusive) | endif

    call s:Search.add()
    call s:Global.get_region()
    call s:Funcs.count_msg(0)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#add_under(visual, whole, inclusive, ...)
    call s:init(a:whole, 0, 1)

    if !a:visual
        let R = s:Global.is_region_at_pos('.')

        "only yank if not on an existing region
        if empty(R) | call s:yank(a:inclusive)
        else | call s:Funcs.set_reg(R.txt) | endif
    endif

    call s:Search.add()
    let R = s:Global.get_region()
    "call s:Global.merge_regions(R.l)
    if !a:0 | call vm#commands#find_next(0, 0) | endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#find_all(visual, whole, inclusive)
    call s:init(a:whole, 0, 1)

    let storepos = getpos('.')
    let s:v.silence = 1
    let seen = []

    call vm#commands#find_under(a:visual, a:whole, a:inclusive)

    while index(seen, s:v.index) == -1
        call add(seen, s:v.index)
        call vm#commands#find_next(0, 0)
    endwhile

    call setpos('.', storepos)
    call s:Funcs.count_msg(1)
endfun


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Find next/previous
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:get_next(n)
    if s:X()
        silent exe "keepjumps normal! ".a:n."g".a:n."y`]"
        call s:Global.get_region()
        call s:Funcs.count_msg(0)
    else
        silent exe "keepjumps normal! ".a:n."g".a:n."y`["
        call vm#commands#add_cursor_at_word(0, 0)
    endif
    let s:v.nav_direction = a:n ==# 'n'? 1 : 0
endfun

fun! s:navigate(force, dir)
    if a:force && s:v.nav_direction != a:dir
        call s:Funcs.msg('Reversed direction.', 1)
        let s:v.nav_direction = a:dir
        return 1
    elseif a:force || @/==''
        let i = a:dir? s:v.index+1 : s:v.index-1
        call s:Global.select_region(i)
        "redraw!
        call s:Funcs.count_msg(0)
        return 1
    endif
endfun

fun! s:skip()
    let r = s:Global.is_region_at_pos('.')
    if empty(r) | call s:navigate(1, s:v.nav_direction)
    else        | call r.remove()
    endif
endfun

fun! s:no_regions()
    if s:v.index == -1 | call s:Funcs.msg('No selected regions.') | return 1 | endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#find_next(skip, nav)
    if s:no_regions() | return | endif

    "rewrite search patterns if moving with hjkl
    if s:simple() && @/=='' | let s:motion = '' | call s:Search.rewrite(1) | endif

    call s:Search.validate()

    "just navigate to next
    if s:navigate(a:nav, 1) | return

    elseif a:skip | call s:skip() | endif
    "skip current match

    call s:get_next('n')
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#find_prev(skip, nav)
    if s:no_regions() | return | endif

    "rewrite search patterns if moving with hjkl
    if s:simple() && @/=='' | let s:motion = '' | call s:Search.rewrite(1) | endif

    call s:Search.validate() | let r = s:Global.is_region_at_pos('.')

    "just navigate to previous
    if s:navigate(a:nav, 0) | return

    elseif a:skip | call s:skip() | endif
    "skip current match

    "move to the beginning of the current match
    if s:X()      | call cursor(r.l, r.a) | endif

    call s:get_next('N')
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#skip(just_remove)
    if s:no_regions() | return | endif

    if a:just_remove
        let r = s:Global.is_region_at_pos('.')
        if !empty(r)
            call r.remove()
            let s:v.index = len(s:Regions)? (s:v.index > 0? s:v.index-1 : 0) : -1
        endif
        call s:Funcs.count_msg(0)

    elseif s:v.nav_direction
        call vm#commands#find_next(1, 0)
    else
        call vm#commands#find_prev(1, 0)
    endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#invert_direction()
    """Invert direction and reselect region."""
    if s:v.auto | return | endif

    for r in s:Regions | let r.dir = !r.dir | endfor

    "invert anchor
    if s:v.direction
        let s:v.direction = 0
        for r in s:Regions | let r.k = r.b | let r.K = r.B | endfor
    else
        let s:v.direction = 1
        for r in s:Regions | let r.k = r.a | let r.K = r.A | endfor
    endif

    call s:Global.update_highlight()
    call s:Global.select_region(s:v.index)
endfun


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Extend regions commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:sublime = { -> !g:VM.is_active && g:VM_sublime_mappings }

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#motion(motion, this, ...)
    if s:sublime()    | call s:init(0, 1, 1)     | call s:Global.new_cursor() | endif
    if s:no_regions() | return                   | endif
    if a:0 && !s:X()  | let g:VM.extend_mode = 1 | endif

    let s:motion = a:motion
    if s:v.auto || ( !g:VM.multiline && s:vertical() )
        let g:VM.multiline = 1 | endif
    call s:call_motion(a:this)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#remap_motion(motion)
    let s:motion = a:motion
    call s:call_motion(a:this)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#end_back(fast, this, ...)
    if s:sublime()    | call s:init(0, 1, 1)     | call s:Global.new_cursor() | endif
    if s:no_regions() | return                   | endif
    if a:0 && !s:X()  | let g:VM.extend_mode = 1 | endif

    let s:motion = a:fast? 'BBW' : 'bbbe'
    call s:call_motion(a:this)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#merge_to_beol(eol, this)
    let s:motion = a:eol? "\<End>" : '0'
    let s:v.merge_to_beol = 1
    let s:merge = 1
    let g:VM.extend_mode = 0
    call s:call_motion(a:this)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#find_motion(motion, char, this, ...)
    if index(['$', '0', '^', '%'], a:motion) >= 0
        let s:motion = a:motion | let s:merge = 1
    elseif a:char != ''
        let s:motion = a:motion.a:char
    else
        let s:motion = a:motion.nr2char(getchar())
    endif

    call s:call_motion(a:this)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:inclusive(c)
    let c = a:c

    if     index(['[', ']'], c) != -1 | let c = '[' | let d = ']'
    elseif index(['(', ')'], c) != -1 | let c = '(' | let d = ')'
    elseif index(['{', '}'], c) != -1 | let c = '{' | let d = '}'
    elseif index(['<', '>'], c) != -1 | let c = '<' | let d = '>'
    else
        let d = nr2char(getchar())
    endif
    return [c, d]
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#shrink_or_enlarge(shrink, this)
    """Reduce/enlarge selection size by 1."""

    "NOTE: macros should disable these mappings in time, but it seems they don't
    "Until I find a reliable way, it's a workaround
    if s:v.auto | return | endif

    if !s:X() | call vm#commands#change_mode(1) | endif

    let dir = s:v.direction

    let s:motion = a:shrink? (dir? 'h':'l') : (dir? 'l':'h')
    call s:call_motion(a:this)

    call vm#commands#invert_direction()

    let s:motion = a:shrink? (dir? 'l':'h') : (dir? 'h':'l')
    call s:call_motion(a:this)

    if s:v.direction != dir | call vm#commands#invert_direction() | endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#select_motion(inclusive, this)

    "NOTE: macros should disable these mappings in time, but it seems they don't
    "Until I find a reliable way, it's a workaround
    if s:v.auto
        if a:this | exe "normal! g"
        else      | exe "normal! G" | endif
        return
    endif

    if !s:X() | call vm#commands#change_mode(0) | endif
    if a:this | call s:Global.new_cursor()      | endif

    let c = nr2char(getchar())
    let a = a:inclusive ? 'F' : 'T'

    if index(['"', "'", '`', '_', '|'], c) != -1
        let d = c

    elseif a:inclusive
        let x = s:inclusive(c) | let c = x[0] | let d = x[1]

    elseif c == '[' | let a = 'T' | let c = '[' | let d = ']'
    elseif c == ']' | let a = 'F' | let c = '[' | let d = ']'
    elseif c == '{' | let a = 'T' | let c = '{' | let d = '}'
    elseif c == '}' | let a = 'F' | let c = '{' | let d = '}'
    elseif c == '(' | let a = 'T' | let c = '(' | let d = ')'
    elseif c == ')' | let a = 'F' | let c = '(' | let d = ')'
    elseif c == '<' | let a = 'T' | let c = '<' | let d = '>'
    elseif c == '>' | let a = 'F' | let c = '<' | let d = '>'

    else
        let d = nr2char(getchar())
    endif

    let b = a==#'F' ? 'f' : 't'

    call vm#commands#motion(a.c, a:this)
    call vm#commands#invert_direction()
    call vm#commands#motion(b.d, a:this)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Motion event
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:only_this        = { -> s:v.only_this || s:v.only_this_always }
let s:can_from_back    = { -> s:motion == '$' && !s:v.direction }
let s:vertical         = { -> index(['j', 'k'],                               s:motion)     >= 0 }
let s:always_from_back = { -> index(['^', '0', 'F', 'T'],                     s:motion)     >= 0 }
let s:forward          = { -> index(['w', 'W', 'e', 'E', 'l', 'f', 't'],      s:motion)     >= 0 }
let s:backwards        = { -> index(['b', 'B', 'F', 'T', 'h', 'k', '0', '^'], s:motion[0])  >= 0 }
let s:simple           = { -> index(['h', 'j', 'k', 'l'],                     s:motion)     >= 0 }

fun! s:call_motion(this)
    let s:v.moving = 1
    let s:v.silence = 1
    let s:v.only_this = a:this
    "let b:VM_backup = copy(b:VM_Selection)

    if !s:v.auto | call vm#commands#move() | return | endif

    "auto section
    let s:merge = 0
    exe "normal! ".s:motion
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#move(...)
    if !s:v.moving | return | endif
    let R = s:Regions[ s:v.index ]
    let s:v.moving -= 1

    if s:v.direction && s:always_from_back()
        call vm#commands#invert_direction()

    elseif s:can_from_back()
        call vm#commands#invert_direction()
    endif

    if s:only_this()
        call s:Regions[s:v.index].move(s:motion) | let s:v.only_this = 0
    else
        for r in s:Regions
            call r.move(s:motion)
        endfor | endif

    "update variables, facing direction, highlighting
    if s:after_move() | return | endif

    let s:v.direction = R.dir
    call s:Global.update_highlight()
    call s:Global.select_region(R.index)

    call s:Funcs.count_msg(0)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:after_move()
    if s:merge | call s:Global.merge_regions() | endif | let s:merge = 0

    if s:always_from_back()
        call vm#commands#invert_direction()
    endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#commands#undo()
    call clearmatches()
    echom b:VM_backup == b:VM_Selection
    let b:VM_Selection = copy(b:VM_backup)
    call s:Global.update_highlight()
    call s:Global.select_region(s:v.index)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
