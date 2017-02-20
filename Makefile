all: clean
	mkdir -p ~/.config/termite/
	(cd ~/.config/termite/ && ln -s "$(PWD)/config")
	(cd ~/.config/termite/ && ln -s "$(PWD)/config" config-dark)
	(cd ~/.config/termite/ && ln -s "$(PWD)/config-light")

clean:
	rm -f \
		~/.config/termite/config \
		~/.config/termite/config-dark \
		~/.config/termite/config-light
