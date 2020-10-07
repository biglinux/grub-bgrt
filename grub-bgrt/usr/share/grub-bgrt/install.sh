#!/bin/bash

# Configurables
GRUB_DIR=/boot/grub/themes
GRUB_THEME=grub-bgrt
FONTSIZE=24 # See README.md

mkdir -p ${GRUB_DIR}/${GRUB_THEME}/

if [[ ! -r /sys/firmware/acpi/bgrt/image ]]; then
# Legacy boot

cp -f theme/theme-legacy.txt theme/theme.txt

# Finally, install the theme

install -d ${GRUB_DIR}/${GRUB_THEME}
install -m644 theme/dejavu-mono-12.pf2 ${GRUB_DIR}/${GRUB_THEME}/
install -m644 theme/lato-${FONTSIZE}.pf2 ${GRUB_DIR}/${GRUB_THEME}/
install -m644 theme/{bgrt,bgrt-legacy,background}.png ${GRUB_DIR}/${GRUB_THEME}/
install -d ${GRUB_DIR}/${GRUB_THEME}/progress_bar/
install -m644 theme/progress_bar/progress_bar_{nw,n,ne,w,c,e,sw,s,se,hl_c}.png ${GRUB_DIR}/${GRUB_THEME}/progress_bar/
install -m644 theme/theme.txt ${GRUB_DIR}/${GRUB_THEME}/
sed -i 's|.*GRUB_GFXMODE=.*|GRUB_GFXMODE="1024x768"|g' /etc/default/grub
cp -Rf theme/icons/ ${GRUB_DIR}/${GRUB_THEME}/

else
# UEFI boot

# OK. Convert the image to PNG (grub doesn't support BMPs)
convert /sys/firmware/acpi/bgrt/image -trim - | convert - -crop '2000x150+0+0' - | convert - -border 2x2 -bordercolor "#000000" - | convert - -trim theme/bgrt.png

# Replace the placeholders with the image offsets
< theme/theme.txt.in awk \
	-v BGRTLEFT="50%-$(($(identify -format "%[fx:w]" theme/bgrt.png) / 2))" \
	-v BGRTTOP=$(</sys/firmware/acpi/bgrt/yoffset) \
	'{gsub (/\$BGRTLEFT\$/, BGRTLEFT);
	  gsub (/\$BGRTTOP\$/, BGRTTOP);
	  print}' > theme/theme.txt

# Finally, install the theme

install -d ${GRUB_DIR}/${GRUB_THEME}
install -m644 theme/dejavu-mono-12.pf2 ${GRUB_DIR}/${GRUB_THEME}/
install -m644 theme/lato-${FONTSIZE}.pf2 ${GRUB_DIR}/${GRUB_THEME}/
install -m644 theme/{bgrt,bgrt-legacy,background}.png ${GRUB_DIR}/${GRUB_THEME}/
install -d ${GRUB_DIR}/${GRUB_THEME}/progress_bar/
install -m644 theme/progress_bar/progress_bar_{nw,n,ne,w,c,e,sw,s,se,hl_c}.png ${GRUB_DIR}/${GRUB_THEME}/progress_bar/
install -m644 theme/theme.txt ${GRUB_DIR}/${GRUB_THEME}/
sed -i 's|.*GRUB_GFXMODE=.*|GRUB_GFXMODE="auto"|g' /etc/default/grub
cp -Rf theme/icons/ ${GRUB_DIR}/${GRUB_THEME}/

fi

