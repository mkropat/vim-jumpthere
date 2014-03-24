source plugin/jumpthere.vim

describe 'jumpthere#Split function'
    before
        let s:cwd = getcwd()
    end

    after
        bufdo! bdelete!
        execute 'cd ' . s:cwd
    end

    it 'expects one argument'
        Expect expr { jumpthere#Split() } to_throw '^Vim.*:E119'
    end

    it 'echoes an error when passed a non-existent path'
        Expect expr { jumpthere#Split('nonexistent_path') } to_throw 'Vim(echoerr):.*path'
    end

    it 'does nothing when passed a blank path'
        call jumpthere#Split('')
        Expect winnr('$') == 1
    end

    it 'does nothing when passed the working directory of the current window'
        call jumpthere#Split(getcwd())
        Expect winnr('$') == 1
    end

    it 'opens a new horizontal split when passed a different directory'
        call jumpthere#Split('t')
        Expect winnr('$') == 2
        Expect winnr() == 1
    end

    it 'sets lcd when a new split is created'
        let l:cwd = getcwd()
        call jumpthere#Split('t')
        Expect getcwd() == l:cwd . '/t'
        wincmd w
        Expect getcwd() == l:cwd
    end

    it 'calls g:JumpThere_OnNewWindow when a new split is created'
        let g:on_new_window_mock_called = 0
        let g:JumpThere_OnNewWindow = function('g:on_new_window_mock')
        call jumpthere#Split('t')
        Expect g:on_new_window_mock_called == 1
    end

    it 'does not assume that g:JumpThere_OnNewWindow exists'
        unlet g:JumpThere_OnNewWindow
        call jumpthere#Split('t')
    end

    it 'switches to the other split when its local working directory equals the passed directory'
        split
        2wincmd w
        lcd t
        1wincmd w

        call jumpthere#Split('t')

        Expect winnr('$') == 2
        Expect winnr() == 2
    end

    it 'switches to the middle split when its local working directory equals the passed directory'
        split
        split
        2wincmd w
        lcd t
        1wincmd w

        call jumpthere#Split('t')

        Expect winnr('$') == 3
        Expect winnr() == 2
    end

    it 'calls g:JumpThere_OnNewWindow when switching windows if the buffer is new'
        split
        2wincmd w
        lcd t
        1wincmd w

        let g:on_new_window_mock_called = 0
        let g:JumpThere_OnNewWindow = function('g:on_new_window_mock')

        call jumpthere#Split('t')

        Expect g:on_new_window_mock_called == 1
    end
end

describe 'jumpthere#VSplit()'
    it 'expects one argument'
        Expect expr { jumpthere#VSplit() } to_throw '^Vim.*:E119'
    end
end

function! g:on_new_window_mock()
    let g:on_new_window_mock_called = 1
endfunction
