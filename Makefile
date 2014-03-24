test:
	@[ -d vim-vspec/.git ] || git submodule update --init vim-vspec
	prove --ext .vim --comments --failure --directives --exec 'vim-vspec/bin/vspec vim-vspec .' t/*.vim
