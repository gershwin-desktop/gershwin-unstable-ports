POUDRIERE_ETC= /zroot/gnustep-build/etc
SCRIPT_DIR= ${.CURDIR}
FUNCS= ${SCRIPT_DIR}/functions.sh

.SUFFIXES:
.SILENT:

ports:
	sh -c ". ${FUNCS}; make_ports"

update:
	sh -c ". ${FUNCS}; update_ports"

clean:
	@sh -c ". ${FUNCS}; clean_ports"
