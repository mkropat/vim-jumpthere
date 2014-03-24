source plugin/jumpthere.vim

describe 'jumpthere#Jump function'
    before
        let s:cwd = getcwd()
    end

    after
        execute 'cd ' . s:cwd
    end

    it 'expects one argument'
        Expect expr { jumpthere#Jump() } to_throw '^Vim.*:E119'
    end

    it 'changes the local working directory to the passed path'
        let l:cwd = getcwd()
        call jumpthere#Jump('t')
        Expect haslocaldir() == 1
        Expect getcwd() == l:cwd . '/t'
    end

    it 'echoes the directory that it changes to'
        "FIXME: I don't know how to test echo
    end

    it 'calls g:JumpThere_ResolvePathHandler if the path does not exist'
        let g:JumpThere_ResolvePathHandler = function('g:lookup_path_mock')
        let g:lookup_path_mock_called = 0
        let g:lookup_path_mock_val = ''
        try
            call jumpthere#Jump('fake jumpthere')
        catch /^jumpthere:DirNotFound$/
        endtry
        Expect g:lookup_path_mock_called == 1
    end
end

describe 'jumpthere#Resolve function'
    it 'expects one argument'
        Expect expr { jumpthere#Resolve() } to_throw '^Vim.*:E119'
    end

    it 'returns cwd if passed an empty string'
        Expect jumpthere#Resolve('') == getcwd()
    end

    it 'throws DirNotFound exception if passed a non-existent path'
        Expect expr { jumpthere#Resolve('nonexistent_path') } to_throw 'jumpthere:DirNotFound'
    end

    it 'returns an absolute path if passed a valid relative path'
        Expect jumpthere#Resolve('t') =~# '^\/.*\/t$'
    end

    it 'returns an absolute path if passed a ~-relative path'
        Expect jumpthere#Resolve('~') =~ '^\/'
    end

    it 'calls g:JumpThere_ResolvePathHandle if the path does not exist'
        let g:JumpThere_ResolvePathHandle = function('g:lookup_path_mock')
        let g:lookup_path_mock_val = '/fake/jumpthere/here'
        Expect jumpthere#Resolve('path somewhere else') == g:lookup_path_mock_val
        Expect g:lookup_path_mock_arg == 'path somewhere else'
    end

    it 'throws DirNotFound exception if g:JumpThere_ResolvePathHandle returns nothing'
        let g:JumpThere_ResolvePathHandle = function('g:lookup_path_mock')
        let g:lookup_path_mock_val = ''
        Expect expr { jumpthere#Resolve('path somewhere else') } to_throw 'jumpthere:DirNotFound'
    end

    it 'trims whitespace at beginning and end of path returned by g:JumpThere_ResolvePathHandle'
        " necessary since autojump output spurious whitespace
        let g:JumpThere_ResolvePathHandle = function('g:lookup_path_mock')
        let g:lookup_path_mock_val = ' 	/fake/jumpthere/here  '
        Expect jumpthere#Resolve('path somewhere else') == '/fake/jumpthere/here'
    end
end

function! g:lookup_path_mock(path)
    let g:lookup_path_mock_called = 1
    let g:lookup_path_mock_arg = a:path
    return g:lookup_path_mock_val
endfunction
