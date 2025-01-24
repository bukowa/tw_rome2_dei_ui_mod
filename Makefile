MOD_FILE_NAME="dei_feature_selector.pack"
IMG_FILE_NAME="dei_feature_selector.png"

build:
	rpfm_cli --game rome_2 pack create --pack-path=${MOD_FILE_NAME}
	rpfm_cli --game rome_2 pack add --pack-path=${MOD_FILE_NAME} -F './mod;'

copy: build
	cp ${MOD_FILE_NAME} "C:\Program Files (x86)\Steam\steamapps\common\Total War Rome II\data"
	cp ${IMG_FILE_NAME} "C:\Program Files (x86)\Steam\steamapps\common\Total War Rome II\data"

kill:
	python -u kill_rome.py && sleep 1 || true

all: build kill copy
	start "" ./runcher_play.lnk
