source plugin/jumpthere.vim

describe 'jumpthere plugin'
    it 'loads'
        Expect g:jumpthere_loaded == 1
    end

    it 'defines g:JumpThere_OnNewWindow'
        Expect exists('g:JumpThere_OnNewWindow') == 1
    end

    it 'has jumpthere#Explore'
        call jumpthere#Explore()
    end

    it 'defines the :Jump, :SplitJump, :VSplitJump, and :TabJump commands'
        Expect exists(':Jump') == 2
        Expect exists(':SplitJump') == 2
        Expect exists(':VSplitJump') == 2
        Expect exists(':TabJump') == 2
    end
end
