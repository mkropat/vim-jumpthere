source plugin/jumpthere.vim

describe 'jumpthere#Tab function'
    before
        let s:cwd = getcwd()
    end

    after
        bufdo! bdelete!
        execute 'cd ' . s:cwd
    end

    it 'expects one argument'
        Expect expr { jumpthere#Tab() } to_throw '^Vim.*:E119'
    end

    it 'echoes an error when passed a non-existent path'
        Expect expr { jumpthere#Tab('invalidpath') } to_throw 'Vim(echoerr):.*path'
    end

    it 'echoes an error when passed a non-existent path'
        Expect expr { jumpthere#Tab('invalidpath') } to_throw 'Vim(echoerr):.*path'
    end

    it 'does nothing when passed a blank path'
        call jumpthere#Tab('')
        Expect winnr('$') == 1
        Expect tabpagenr('$') == 1
    end

    it 'does nothing when passed the working directory of the current window'
        call jumpthere#Tab(getcwd())
        Expect winnr('$') == 1
        Expect tabpagenr('$') == 1
    end

    it 'opens a new tab when passed a different directory'
        put! ='non-empty buffer'
        call jumpthere#Tab('t')
        Expect tabpagenr('$') == 2
        Expect tabpagenr() == 2
    end

    it 'sets lcd when a new tab is created'
        put! ='non-empty buffer'
        let l:cwd = getcwd()
        call jumpthere#Tab('t')
        Expect getcwd() == l:cwd . '/t'
        tabnext
        Expect getcwd() == l:cwd
    end

    it 'calls g:JumpThere_OnNewWindow when a new tab is created'
        let g:on_new_window_mock_called = 0
        let g:JumpThere_OnNewWindow = function('g:on_new_window_mock')
        call jumpthere#Tab('t')
        Expect g:on_new_window_mock_called == 1
    end

    it 'does not assume that g:JumpThere_OnNewWindow exists'
        unlet g:JumpThere_OnNewWindow
        call jumpthere#Tab('t')
    end

    it 'does not open a new tab when the current tab is an empty buffer'
        call jumpthere#Tab('t')
        Expect tabpagenr('$') == 1
    end

    it 'does open a new when the current tab has multiple windows'
        split
        call jumpthere#Tab('t')
        Expect tabpagenr('$') == 2
    end

    it 'switches to the other split when its local working directory equals the passed directory'
        split
        2wincmd w
        lcd t
        1wincmd w

        call jumpthere#Tab('t')

        Expect winnr() == 2
    end

    it 'switches to the other tab that is in the passed directory'
        tabnew
        lcd t
        1tabnext

        call jumpthere#Tab('t')

        Expect tabpagenr('$') == 2
        Expect tabpagenr() == 2
    end

    it 'switches to the second window in the other tab that is in the passed directory'
        tabnew
        split
        2wincmd w
        lcd t
        1wincmd w
        1tabnext

        call jumpthere#Tab('t')

        Expect tabpagenr('$') == 2
        Expect tabpagenr() == 2
        Expect winnr() == 2
    end

    it 'calls g:JumpThere_OnNewWindow when switching tabs if the buffer is new'
        tabnew
        lcd t
        1tabnext

        let g:on_new_window_mock_called = 0
        let g:JumpThere_OnNewWindow = function('g:on_new_window_mock')
        call jumpthere#Tab('t')
        Expect g:on_new_window_mock_called == 1
    end
end

function! g:on_new_window_mock()
    let g:on_new_window_mock_called = 1
endfunction
