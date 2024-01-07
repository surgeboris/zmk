all: build_left build_reset build_right
	make own_back
build_left: own start
	docker exec -w /zmk/app zmk west build -p -d build/left -b nice_nano_v2 -- -DSHIELD="corne_left nice_view_adapter nice_view"
build_reset: own start
	docker exec -w /zmk/app zmk west build -p -d build/reset -b nice_nano_v2 -- -DSHIELD="settings_reset"; make own_back
build_right: own start
	docker exec -w /zmk/app zmk west build -p -d build/right -b nice_nano_v2 -- -DSHIELD="corne_right nice_view_adapter nice_view"
clean: own_back
	rm -rf ./app/build
clean_all: clean
	rm -rf ./.west && docker stop zmk && docker rm zmk
cli: own start
	docker exec -w /zmk -it zmk /bin/bash && make
flash_left: own_back
	cp app/build/left/zephyr/zmk.uf2 /run/media/$$(whoami)/NICENANO/CURRENT.UF2
flash_reset: own_back
	cp app/build/reset/zephyr/zmk.uf2 /run/media/$$(whoami)/NICENANO/CURRENT.UF2
flash_right: own_back
	cp app/build/right/zephyr/zmk.uf2 /run/media/$$(whoami)/NICENANO/CURRENT.UF2
init: own
	docker run -d --name zmk -v .:/zmk -w /zmk docker.io/zmkfirmware/zmk-dev-arm:3.5 tail -f ./Makefile && docker exec zmk /bin/bash -c "west init -l app" && docker exec zmk /bin/bash -c "west update"
own:
	sudo chown -R root:root .
own_back:
	sudo chown -R $$(id -u):$$(id -g) .
start:
	sudo rc-service docker start && sleep 3 && docker start zmk
