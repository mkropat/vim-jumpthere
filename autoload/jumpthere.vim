function! jumpthere#Jump(dir)
    let l:dir = jumpthere#Resolve(a:dir)
    execute 'lcd ' . l:dir
    echo getcwd()
endfunction

function! jumpthere#Resolve(dir)
    if exists('g:JumpThere_ResolvePathHandler')
        try
            return s:TryResolveDir(a:dir)
        catch /^jumpthere:DirNotFound$/
            return s:CallResolvePathHandler(g:JumpThere_ResolvePathHandler, a:dir)
        endtry
    else
        return s:TryResolveDir(a:dir)
    endif
endfunction

function! jumpthere#Split(dir)
    call s:GenericSplit(function('s:Split'), a:dir)
endfunction

function! jumpthere#VSplit(dir)
    call s:GenericSplit(function('s:VSplit'), a:dir)
endfunction

function! jumpthere#Tab(dir)
    try
        call s:Tab(jumpthere#Resolve(a:dir))
    catch /^jumpthere:DirNotFound$/
        echoerr 'No such path'
    endtry
endfunction

function! jumpthere#Autojump(path)
    return system('autojump ' . shellescape(a:path))
endfunction

function! s:GenericSplit(SplitFn, dir)
    try
        call s:DoGenericSplit(a:SplitFn, jumpthere#Resolve(a:dir))
    catch /^jumpthere:DirNotFound$/
        echoerr 'No such path'
    endtry
endfunction

function! s:DoGenericSplit(SplitFn, resolved_dir)
    try
        call s:GotoWindow(function('s:CwdEquals'), a:resolved_dir)
        if s:IsBufferNew()
            call s:CallIfExists('g:JumpThere_OnNewWindow')
        endif
    catch /^jumpthere:WindowNotFound$/
        call a:SplitFn()
        execute 'lcd ' . a:resolved_dir
        call s:CallIfExists('g:JumpThere_OnNewWindow')
    endtry
endfunction

function! jumpthere#Explore()
    if exists(':Explore')
        Explore .
    endif
endfunction

function! s:Tab(resolved_dir)
    try
        call s:GotoTabWindow(function('s:CwdEquals'), a:resolved_dir)
        if s:IsBufferNew()
            call s:CallIfExists('g:JumpThere_OnNewWindow')
        endif
    catch /^jumpthere:WindowNotFound$/
        if s:IsBufferNew() == 0 || winnr('$') > 1
            tabnew
        end
        execute 'lcd ' . a:resolved_dir
        call s:CallIfExists('g:JumpThere_OnNewWindow')
    endtry
endfunction

function! s:CwdEquals(dir)
    return getcwd() ==# a:dir
endfunction

function! s:GotoWindow(PredicateFn, ...)
    let l:curwin = winnr()
    for i in range(winnr('$'))
        execute i + 1 'wincmd w'
        if call(a:PredicateFn, a:000)
            return
        endif
    endfor
    execute l:curwin . 'wincmd w'
    throw 'jumpthere:WindowNotFound'
endfunction

function! s:GotoTabWindow(PredicateFn, ...)
    let l:curtab = tabpagenr()
    for i in range(tabpagenr('$'))
        execute i + 1 . 'tabnext'
        let l:curwin = winnr()
        for j in range(winnr('$'))
            execute j + 1 . 'wincmd w'
            if call(a:PredicateFn, a:000)
                return
            end
        endfor
        execute l:curwin . 'wincmd w'
    endfor
    execute l:curtab . 'tabnext'
    throw 'jumpthere:WindowNotFound'
endfunction

function! s:Split()
    split
endfunction

function! s:VSplit()
    vsplit
endfunction

function! s:TryResolveDir(dir)
    let l:dir = s:ExpandRelativePath(expand(a:dir))
    if isdirectory(l:dir) == 0
        throw 'jumpthere:DirNotFound'
    endif
    return l:dir
endfunction

function! s:CallResolvePathHandler(ResolvePathHandler, dir)
    let l:dir = s:Strip(a:ResolvePathHandler(a:dir))
    if l:dir == ''
        throw 'jumpthere:DirNotFound'
    endif
    return l:dir
endfunction

function! s:ExpandRelativePath(path)
    if a:path == ''
        return getcwd()
    elseif s:StartsWith(a:path, '/')
        return getcwd() . '/' . a:path
    else
        return a:path
    endif
endfunction

function! s:IsBufferNew()
    return bufname('%') == '' && s:IsBufferBlank()
endfunction

function! s:IsBufferBlank()
    return line('$') == 1 && getline(1) == ''
endfunction

function! s:CallIfExists(fn_name, ...)
    if exists(a:fn_name)
        execute 'call ' . a:fn_name . '()'
    endif
endfunction

function! s:StartsWith(str, prefix)
    return stridx(a:str, a:prefix) != 0
endfunction

function! s:Strip(string)
    " Based on implementation by DrAl (http://stackoverflow.com/a/4479072/27581)
    return substitute(a:string, '^\_\s*\(.\{-}\)\_\s*$', '\1', '')
endfunction
