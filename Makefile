all: clean
	mkdir -p ~/.config/termite/
	(cd ~/.config/termite/ && ln -s "$(shell pwd)/config")
	(cd ~/.config/termite/ && ln -s "$(shell pwd)/config" config-dark)
	(cd ~/.config/termite/ && ln -s "$(shell pwd)/config-light")

clean:
	[ -L ~/.config/termite/config -o ! -e ~/.config/termite/config ] && \
		rm -f ~/.config/termite/config
	[ -L ~/.config/termite/config-dark -o ! -e ~/.config/termite/config-dark ] && \
		rm -f ~/.config/termite/config-dark
	[ -L ~/.config/termite/config-light -o ! -e ~/.config/termite/config-light ] && \
		rm -f ~/.config/termite/config-light
