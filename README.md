# vim-jumpthere

*Lightweight project switcher*

**jumpthere.vim** gives you a set of commands to jump to a Vim window --
whether in another split or a different tab -- that has a given local working
directory. If no such window exists, **jumpthere.vim** opens a new tab or split
(depending on the command used) with the local directory you specified.

If each of your projects exists in a separate directory, **jumpthere.vim**
gives you a single command that will jump to a given project -- no matter which
Vim window it might be in, or whether or not the project has even been opened
yet.

## Autojump Integration

Directory paths passed to **jumpthere.vim** can be either relative or absolute
paths, like you'd expect. But, if you have
[autojump](https://github.com/joelthelion/autojump) installed, you may also
pass any part of a desired path, and autojump will figure out which directory
you meant.

## Installation

### Vundle

If you're using [Vundle](https://github.com/gmarik/Vundle.vim), add the following to your `.vimrc`:

    Bundle 'mkropat/vim-jumpthere'

Then run `:BundleInstall` from Vim.

### Pathogen

If you're using [pathogen.vim](https://github.com/tpope/vim-pathogen), run the following shell commands:

    cd ~/vim/bundle
    git clone https://github.com/mkropat/vim-jumpthere.git

## Interactive Use

The first command operates on the current window:

* `:Jump` -- set the `:lcd` of the current window (using autojump, if available)

The other three commands switch to the window with a specified working
directory, opening a new window if it doesn't exist.

* `:SplitJump` -- jump to a matching split on the same tab, otherwise open a new horizontal split
* `:VSplitJump` -- jump to a matching split on the same tab, otherwise open a new vertical split
* `:TabJump` -- jump to a matching window in any open tab, otherwise open a new tab

## Key Mapping

Perhaps where **jumpthere.vim** shines most is in mapping `:*Jump` commands to
key strokes. If you added the following to your `.vimrc`:

    nnoremap <Leader>jh :TabJump ~<CR>

Then no matter where you were in Vim, you could always open up a tab with your
home directory using the <kbd>Leader</kbd>-<kbd>j</kbd>-<kbd>h</kbd> key
sequence. That's a lot easier than manually typing in `:tabnew` and possibly
`:lcd` to open it, then later when you're working in some different tab have to
figure out that you have to go 2 tabs back to bring up the home tab.


## Hooks

**jumpthere.vim** is extensible in a few different ways.

### g:JumpThere_OnNewWindow

*Do something when opening a new tab or split*

After **jumpthere.vim** creates a new window, it first runs `:lcd` to change to
the specified directory, then it calls the Function reference assigned to
`g:JumpThere_OnNewWindow`. The default handler runs the *netrw* plugin on the
directory, but you can override this behavior by assigning your own function
reference to the hook.

#### Default Implementation

    let g:JumpThere_OnNewWindow = function('jumpthere#Explore')

    function! jumpthere#Explore()
        if exists(':Explore')
            Explore
        endif
    endfunction

### g:JumpThere_ResolvePathHandler

*In case something better than autojump comes along*

When resolving a user-supplied path to an absolute directory, **jumpthere.vim**
first checks to see if the literal path exists. If the directory doesn't exist,
it calls `g:JumpThere_ResolvePathHandler` to see if it can resolve the path.
The default implementation calls the system command `autojump`, but you can
override it with any behavior you want.

#### Default Implementation

    let g:JumpThere_PathLookupHandler = function('jumpthere#Autojump')

    function! jumpthere#Autojump(path)
        return system('autojump ' . shellescape(a:path))
    endfunction

### Future Hooks

If you want to see a new hook, let me know. Just submit a new Issue that
describes what you're trying to accomplish.

One idea I had is to let the user pass an `OnNewWindow` handler when calling
`jumpthere#SplitJump` or `jumpthere#SplitTab` so that users can define
initialization functions on a per-project basis instead of globally.

## License

Copyright © Michael Kropat.  Distributed under the same terms as Vim itself.
See `:help license`.
