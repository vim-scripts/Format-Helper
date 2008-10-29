" Title:	Vim Format Helper
" Maintainer:	Frank Sun <frank.sun.319@gmail.com>
" Description:
" Last Change:	2008-10-28
" Version:	1.7

" Only do this when not done yet for this buffer
if exists("b:format_helper")
    finish
endif

let b:format_helper = 1

let cpo_save = &cpo
set cpo-=C


"""""""""""""""""""""""""""""""""""""""""""""""""""
"              Predefined variables		  "
"""""""""""""""""""""""""""""""""""""""""""""""""""
" global variable to control alignation effect
let g:format_align_offset = 0

" global variables to control effect of enumerate list and number list
let g:format_list_ceil = 0
let g:format_list_floor = 0
let g:format_list_indent = 0
let g:format_list_max_scope = 100
let s:format_list_interval = 1

" global variables to control effect of head line and foot line
let g:format_head_ceil = 0
let g:format_foot_floor = 0
let g:format_headfoot_indent = 0

" global variables to control effect of text block
let g:format_block_ceil = 0
let g:format_block_floor = 0
let g:format_block_indent = 0
let g:format_block_internal_ceil = 0
let g:format_block_internal_floor = 0
let s:format_block_interval = 3


"""""""""""""""""""""""""""""""""""""""""""""""""""
"              Predefined dictionaries		  "
"""""""""""""""""""""""""""""""""""""""""""""""""""
let s:List = {}
let s:List.Enumeratelist = {}
let s:List.Numberlist = {}

let s:Headfoot = {}

let s:Textblock = {}

let s:Docinfo = {}


"""""""""""""""""""""""""""""""""""""""""""""""""""
"              Predefined options		  "
"""""""""""""""""""""""""""""""""""""""""""""""""""
set cmdheight=2
set complete+=k
set completeopt=menuone,preview

""""""""""""""""""""""""""""""""""""""""""""
" Add location of your local dictionary here
"set dictionary+=?
""""""""""""""""""""""""""""""""""""""""""""

set laststatus=2
set pumheight=15

""""""""""""""""""""""""""""""""""""""""""""
" If you like system default <Tab> policy, 
" please comment below 3 lines.
set expandtab
set smarttab
set shiftwidth=4
""""""""""""""""""""""""""""""""""""""""""""

set showmatch
set wildmenu


"""""""""""""""""""""""""""""""""""""""""""""""""""
"              Predefined commands		  "
"""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto-match alignation with window's width and line number
command! -range -nargs=0 Left <line1>,<line2>left
command! -range -nargs=0 Center <line1>,<line2>call <SID>:AlignLines("center")
command! -range -nargs=0 Right <line1>,<line2>call <SID>:AlignLines("right")

command! -range -nargs=1 AddEnumerateList <line1>,<line2>call s:List.Enumeratelist.EnumerateList(<f-args>,'a')
command! -range -nargs=1 DelEnumerateList <line1>,<line2>call s:List.Enumeratelist.EnumerateList(<f-args>,'d')

command! -range -nargs=1 HeadLine <line1>call s:Headfoot.Head(<f-args>)
command! -range -nargs=1 FootLine <line1>call s:Headfoot.Foot(<f-args>)

command! -range -nargs=1 AddNumberList <line1>,<line2>call s:List.Numberlist.NumberList(<f-args>,'a')
command! -range -nargs=1 DelNumberList <line1>,<line2>call s:List.Numberlist.NumberList(<f-args>,'d')

command! -range -nargs=1 AddTextBlock <line1>,<line2>call s:Textblock.TextBlock(<f-args>,'a')
command! -range -nargs=1 DelTextBlock <line1>,<line2>call s:Textblock.TextBlock(<f-args>,'d')

" Calculate statistics informations of selected lines, include:
"	(1) number of all characters
"	(2) number of non-space characters
"	(3) number of words
"	(4) number of lines
"	(5) number of non-empty lines
command! -range -nargs=0 Statistics <line1>,<line2>call s:Docinfo.Statistics()

"""""""""""""""""""""""""""""""""""""""""""""""""""
"              Predefined maps			  "
"""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto-complete parenthesis
inoremap ( ()<ESC>i
inoremap <silent>) <c-r>=<SID>:ClosePair(')')<CR>
inoremap { {}<ESC>i
inoremap <silent>} <c-r>=<SID>:ClosePair('}')<CR>
inoremap [ []<ESC>i
inoremap <silent>] <c-r>=<SID>:ClosePair(']')<CR>
inoremap < <><ESC>i
inoremap <silent>> <c-r>=<SID>:ClosePair('>')<CR>

" bind function to the tab key
inoremap <silent><Tab> <C-R>=<SID>:SuperCleverTab()<CR>

" Binding your own hot-key maps here:
" let g:mapleader=','
" noremap <leader><source> <destination>
" nnoremap <leader><source> <destination>
" inoremap <leader><source> <destination>
" vnoremap <leader><source> <destination>


"""""""""""""""""""""""""""""""""""""""""""""""""""
"              Predefined functions		  "
"""""""""""""""""""""""""""""""""""""""""""""""""""
function! <SID>:AlignLines(direction) range
    execute a:firstline.','.a:lastline.'s/\s*$//'
    execute a:firstline.','.a:lastline.' '.a:direction.(<SID>:RealTextWidth() - 2 * g:format_align_offset)
endfunction <SID>:AlignLines

function! <SID>:ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<Right>"
    else
        return a:char
    endif
endfunction <SID>:ClosePair

" flag == 'i': include spaces
" flag == 'e': exclude spaces
function! s:Docinfo.CountCharacters(beg,end,flag)
    let characterscount = 0
    if a:flag == 'i'
        for line in getline(a:beg,a:end)
            let characterscount += len(line)
        endfor
    elseif a:flag == 'e'
        for line in getline(a:beg,a:end)
            let characterscount += len(substitute(line,'\s','','g'))
        endfor
    endif
    return characterscount
endfunction s:Docinfo.CountCharacters

" flag == 'i': include empty lines
" flag == 'e': exclude empty lines
function! s:Docinfo.CountLines(beg,end,flag)
    if a:flag == 'i'
        return a:end - a:beg + 1
    elseif a:flag == 'e'
        let linescount = 0
        for line in getline(a:beg,a:end)
            if line !~ '^\s*$'
                let linescount += 1
            endif
        endfor
        return linescount
    endif
endfunction s:Docinfo.CountLines

function! s:Docinfo.CountWords(beg,end)
    let wordscount = 0
    for line in getline(a:beg,a:end)
        let wordscount += len(split(line,'\W\+'))
    endfor
    return wordscount
endfunction s:Docinfo.CountWords

function <SID>:InsertLinesUpwards(currentlineno,lines)
    if a:lines <= 0
        return
    endif
    execute a:currentlineno
    execute 'normal ' . a:lines . 'O'
    execute 'normal ' . (a:lines - 1) . 'j'
endfunction <SID>:InsertLinesUpwards

function <SID>:InsertLinesDownwards(currentlineno,lines)
    if a:lines <= 0
        return
    endif
    execute a:currentlineno
    execute 'normal ' . a:lines . 'o'
    execute 'normal ' . a:lines . 'k'
endfunction <SID>:InsertLinesDownwards

function! s:List.Enumeratelist.EnumerateList(style,action) range
    if a:action == 'a'
        call s:List.Enumeratelist.Add(a:firstline,a:lastline,a:style)
    elseif a:action == 'd'
        call s:List.Enumeratelist.Del(a:firstline,a:lastline,a:style)
    endif
endfunction s:List.Enumeratelist.EnumerateList

function! s:List.Enumeratelist.Add(beg,end,style)
    let linenum = a:beg
    let indentspaces = <SID>:MakeCharacters(g:format_list_indent,' ')
    let intervalspaces = <SID>:MakeCharacters(s:format_list_interval,' ')
    while linenum <= a:end
        let line = getline(linenum)
        if line !~ '^\s*$'
            call setline(linenum,indentspaces.a:style.intervalspaces.substitute(line,'^\s*','',""))
        endif
        let linenum += 1
    endwhile
    call <SID>:InsertLinesUpwards(a:beg,g:format_list_ceil)
    call <SID>:InsertLinesDownwards(a:end + g:format_list_ceil,g:format_list_floor)
endfunction s:List.Enumeratelist.Add

" any line in selected area which matches:
" 'sytle.space(s:format_list_interval)'
" will be deleted
function! s:List.Enumeratelist.Del(beg,end,style)
    let linenum = a:beg
    let spaces = <SID>:MakeCharacters(s:format_list_interval,' ')
    while linenum <= a:end
        let line = substitute(getline(linenum),'^\s*','','')
        " style would not be null
        if line[:(len(a:style) + s:format_list_interval - 1)] == (a:style . spaces)
            call setline(linenum,substitute(line[len(a:style):],'^\s*','',''))
        endif
        let linenum += 1
    endwhile
endfunction s:List.Enumeratelist.Del

function! s:Headfoot.Head(symbol) range
    let sym = a:symbol[0]
    call s:Headfoot.AddHeadFoot(a:firstline,sym,'h')
endfunction s:Headfoot.Head

function! s:Headfoot.Foot(symbol) range
    let sym = a:symbol[0]
    call s:Headfoot.AddHeadFoot(a:firstline,sym,'f')
endfunction s:Headfoot.Foot

function! s:Headfoot.AddHeadFoot(lineno,symbol,type)
    execute a:lineno
    if getline('.') =~ '^\s*$'
        return
    endif
    execute '.s/^\s*//'
    execute '.s/\s*$//'
    let spaces = <SID>:MakeCharacters(g:format_headfoot_indent,' ')
    if a:type == 'h'
        execute "normal yyPVr" . a:symbol
        call <SID>:InsertLinesUpwards('.',g:format_head_ceil)
        call setline(line('.'),spaces . getline('.'))
        normal j
        call setline(line('.'),spaces . getline('.'))
    elseif a:type == 'f'
        execute "normal yypVr" . a:symbol
        call <SID>:InsertLinesDownwards('.',g:format_foot_floor)
        call setline(line('.'),spaces . getline('.'))
        normal k
        call setline(line('.'),spaces . getline('.'))
    endif
endfunction s:Headfoot.AddHeadFoot

function! <SID>:LongestLength(beg,end)
    let maxlength = len(substitute(substitute(getline(a:beg),'^\s*','',''),'\s*$','',''))
    for line in getline(a:beg,a:end)
        let line = substitute(substitute(line,'^\s*','',''),'\s*$','','')
        let maxlength = max([maxlength,len(line)])
    endfor
    return maxlength
endfunction <SID>:LongestLength

function! <SID>:MakeCharacters(width,character)
    let characters = ''
    for characterscount in range(1,a:width)
        let characters .= a:character
    endfor
    return characters
endfunction <SID>:MakeCharacters

" NOTE: string should not include space
function! <SID>:ParseQuestionMark(string)
    let idxstart = match(a:string,'?')
    if idxstart >= 0
        " if ? located on the end of line, then return len(line)
        let poststart = match(a:string,'?\zs')
        return [strpart(a:string,0,idxstart),'?',strpart(a:string,poststart,len(a:string)-poststart)]
    endif
    return ['','','']
endfunction <SID>:ParseQuestionMark

" NOTE: string should not include space
function! <SID>:ParseNumber(string)
    let idxstart = match(a:string,'\d')
    if idxstart >= 0
        " if \d\+ located on the end of line, then return len(line)
        let poststart = match(a:string,'\d\+\zs')
        return [strpart(a:string,0,idxstart),strpart(a:string,idxstart,poststart-idxstart),strpart(a:string,poststart,len(a:string)-poststart)]
    endif
    return ['','','']
endfunction <SID>:ParseNumber

function! <SID>:StyleParser(style)
    let style = substitute(a:style,'\s','','g')
    let tokens = <SID>:ParseQuestionMark(a:style)
    if tokens[1] != ''
        return tokens
    endif
    let tokens = <SID>:ParseNumber(a:style)
    return tokens
endfunction <SID>:StyleParser

function! <SID>:LastNumberList(lineno,presegment,postsegment)
    let inf = max([1,a:lineno - g:format_list_max_scope])
    let ln = a:lineno
    while ln >= inf
        let line = substitute(getline(ln),'^\s*','','')
        let idxstart = match(line,'\d')
        if strpart(line,0,idxstart) == a:presegment
            let line = strpart(line,idxstart,(len(line) - idxstart))
            if line !~ '^\d\+'
                let ln -= 1
                continue
            endif
            let number = strpart(line,0,match(line,'\d\+\zs'))
            let line = substitute(line,'^\d\+','','')
            let spaces = <SID>:MakeCharacters(s:format_list_interval,' ')
            if strpart(line,0,(len(a:postsegment)+s:format_list_interval)) == a:postsegment . spaces
                return number
            endif
        endif
        let ln -= 1
    endwhile
    return 0
endfunction <SID>:LastNumberList

function! s:List.Numberlist.NumberList(style,action) range
    let parsed = <SID>:StyleParser(a:style)
    if parsed[1] == ''
        return
    endif
    if a:action == 'a'
        call s:List.Numberlist.Add(a:firstline,a:lastline,parsed[0],parsed[1],parsed[2])
    elseif a:action == 'd'
        call s:List.Numberlist.Del(a:firstline,a:lastline,parsed[0],parsed[2])
    endif
endfunction s:List.Numberlist.NumberList

" action == 'a': add number list to selected lines;
" action == 'd': cancel number list from selected lines.
function! s:List.Numberlist.Add(beg,end,presegment,index,postsegment)
    let indentspaces = <SID>:MakeCharacters(g:format_list_indent,' ')
    let intervalspaces = <SID>:MakeCharacters(s:format_list_interval,' ')
    let lineno = a:end
    let idx = s:Docinfo.CountLines(a:beg,a:end,'e')
    let idx += (a:index == '?' ? <SID>:LastNumberList(lineno,a:presegment,a:postsegment) : a:index - 1)
    let spaces = ''
    while lineno >= a:beg
        let line = substitute(getline(lineno),'^\s*','','')
        if line !~ '^\s*$'
            call setline(lineno,indentspaces.spaces.a:presegment.idx.a:postsegment.intervalspaces.line)
            let idx -= 1
            if idx =~ '^9\d*$'
                let spaces .= ' '
            endif
        endif
        let lineno -= 1
    endwhile
    call <SID>:InsertLinesUpwards(a:beg,g:format_list_ceil)
    call <SID>:InsertLinesDownwards(a:end + g:format_list_ceil,g:format_list_floor)
endfunction s:List.Numberlist.Add

" any line in selected area which matches:
" 'presegment.\d\+.postsegment.space(s:format_list_interval)'
" will be deleted
function! s:List.Numberlist.Del(beg,end,presegment,postsegment)
    let lineno = a:end
    while lineno >= a:beg
        let line = substitute(getline(lineno),'^\s*','','')
        if a:presegment !~ '^\s*$'
            if line[:(len(a:presegment)-1)] == a:presegment
                let line = line[len(a:presegment):]
            else
                let lineno -= 1
                continue
            endif
        endif
        if line =~ '^\d\+'
            let line = substitute(line,'^\d\+','','')
        else
            let lineno -= 1
            continue
        endif
        if a:postsegment !~ '^\s*$'
            let spaces = <SID>:MakeCharacters(s:format_list_interval,' ')
            if line[:(len(a:postsegment) + s:format_list_interval - 1)] == (a:postsegment . spaces)
                call setline(lineno,substitute(line[len(a:postsegment):],'^\s*','',''))
            endif
        else
            call setline(lineno,substitute(line,'^\s*','',''))
        endif
        let lineno -= 1
    endwhile
endfunction s:List.Numberlist.Del

function! <SID>:RealTextWidth()
    if &number == 1
        let digits = len(line('$')) + 1
        let headwidth = (digits <= &numberwidth ? &numberwidth : digits)
        return winwidth(0) - headwidth
    else
        return winwidth(0)
    endif
endfunction <SID>:RealTextWidth

function! s:Docinfo.Statistics() range
    echo "Characters (with spaces): "(s:Docinfo.CountCharacters(a:firstline,a:lastline,'i'))
    echo "Characters (no spaces): "(s:Docinfo.CountCharacters(a:firstline,a:lastline,'e'))
    echo "Words: "(s:Docinfo.CountWords(a:firstline,a:lastline))
    echo "Lines (with empty): "(s:Docinfo.CountLines(a:firstline,a:lastline,'i'))
    echo "Lines (no empty): "(s:Docinfo.CountLines(a:firstline,a:lastline,'e'))
endfunction s:Docinfo.Statistics

function! <SID>:SuperCleverTab()
    "check if at beginning of line or after a space
    let line = getline('.')
    if strpart(line, 0, col('.')-1) =~ '^\s*$' || line[col('.') - 2] !~ '[A-Za-z]'
        return "\<Tab>"
    else
        " do we have omni completion available
        if &omnifunc != ''
            "use omni-completion 1. priority
            return "\<C-X>\<C-O>"
        else
            " use known-word completion and known words in current file and words in headers
            " option 'complete' should includes 'k' and 'd'
            return "\<C-N>"
        endif
    endif
endfunction <SID>:SuperCleverTab

function! s:Textblock.TextBlock(symbol,action) range
    let sym = a:symbol[0]
    if a:action == 'a'
        call s:Textblock.Add(a:firstline,a:lastline,sym)
    elseif a:action == 'd'
        call s:Textblock.Del(a:firstline,a:lastline,sym)
    endif
endfunction s:Textblock.TextBlock

function! s:Textblock.Add(beg,end,symbol)
    let framewidth = <SID>:LongestLength(a:beg,a:end) + 2 * s:format_block_interval + 2
    if framewidth > <SID>:RealTextWidth() - g:format_block_indent
        echo "Some lines' length larger than text width."
        return
    else
        let lineno = a:beg
        let indentspaces = <SID>:MakeCharacters(g:format_block_indent,' ')
        let intervalspaces = <SID>:MakeCharacters(s:format_block_interval,' ')
        while lineno <= a:end
            let line = substitute(substitute(substitute(getline(lineno),'^\s*','',''),'\s*$','',''),'\t',' ','g')
            let intervalspaces = <SID>:MakeCharacters(s:format_block_interval,' ')
            call setline(lineno,indentspaces.a:symbol.intervalspaces.line.<SID>:MakeCharacters(framewidth-len(line)-s:format_block_interval-2,' ').a:symbol)
            let lineno += 1
        endwhile
        let internalceilfloor = indentspaces.a:symbol.<SID>:MakeCharacters(framewidth - 2,' ').a:symbol
        let boundary = indentspaces.<SID>:MakeCharacters(framewidth,a:symbol)
        " build ceil components
        call <SID>:InsertLinesUpwards(a:beg,(g:format_block_ceil+g:format_block_internal_ceil+1))
        let lineno = a:beg + g:format_block_ceil
        call setline(lineno,boundary)
        for lineno in range(lineno + 1,lineno + g:format_block_internal_ceil)
            call setline(lineno,internalceilfloor)
        endfor
        " build floor components
        let lineno = a:end + g:format_block_ceil + g:format_block_internal_ceil + 1
        call <SID>:InsertLinesDownwards(lineno,(g:format_block_internal_floor+g:format_block_floor+1))
        for lineno in range(lineno+1,lineno+g:format_block_internal_floor)
            call setline(lineno,internalceilfloor)
        endfor
        call setline(lineno + 1,boundary)
    endif
endfunction s:Textblock.Add

function! s:Textblock.Del(beg,end,symbol)
    let lineno = a:beg
    while lineno <= a:end
        let line = substitute(substitute(getline(lineno),'^\s*','',''),'\s*$','','')
        let spaces = <SID>:MakeCharacters(s:format_block_interval,' ')
        if line[:(s:format_block_interval)] == (a:symbol . spaces)
            let line = line[(s:format_block_interval+1):]
            if line[len(line) - 1] == a:symbol
                call setline(lineno,substitute(line[:(len(line) - 2)],'\s*$','',''))
            endif
        endif
        if line == <SID>:MakeCharacters(len(line),a:symbol)
            call setline(lineno,'')
        endif
        let lineno += 1
    endwhile
endfunction s:Textblock.Del


""""""""""""""""""""""""""""""""""""""""""""""""""

let &cpo = cpo_save

" Vim Format Helper
