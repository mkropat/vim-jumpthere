let g:jumpthere_loaded = 1

let g:JumpThere_OnNewWindow = function('jumpthere#Explore')

if executable('autojump')
    let g:JumpThere_ResolvePathHandler = function('jumpthere#Autojump')
endif

command! -nargs=1 -complete=dir SplitJump call jumpthere#Split(<f-args>)
command! -nargs=1 -complete=dir VSplitJump call jumpthere#VSplit(<f-args>)
command! -nargs=1 -complete=dir TabJump call jumpthere#Tab(<f-args>)
command! -nargs=1 -complete=dir Jump call jumpthere#Jump(<f-args>)
