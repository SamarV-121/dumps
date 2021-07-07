#!/usr/bin/env bash
GITHUB_WORKFLOW="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"

function editTGmsg() {
	curl -s "https://api.telegram.org/bot${TELEGRAM_TOKEN}/editMessageText" --data "text=${*}&chat_id=$CHAT_ID&message_id=$MESSAGE_ID&disable_web_page_preview=true&parse_mode=HTML"
}

if [[ -f $URL ]]; then
	cp -v "$URL" .
	editTGmsg "Found file locally"
else
	editTGmsg "Starting <a href=\"$URL\">dump</a> on <a href=\"$GITHUB_WORKFLOW\">GitHub Actions</a>"
	if [[ $URL =~ drive.google.com ]]; then
		echo "Google Drive URL detected"
		FILE_ID="$(echo "${URL:?}" | sed -r 's/.*([0-9a-zA-Z_-]{33}).*/\1/')"
		echo "File ID is ${FILE_ID}"
		CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$FILE_ID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
		aria2c --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM&id=$FILE_ID" || exit 1
		rm /tmp/cookies.txt
	elif [[ $URL =~ mega.nz ]]; then
		megadl "'$URL'" || exit 1
	else
		# Try to download with aria, else wget. Clean the directory each time.
		aria2c -q -s16 -x16 "${URL}" || {
			rm -fv ./*
			wget "${URL}" || {
				echo "Download failed. Exiting."
				editTGmsg "Failed to download the file."
				exit 1
			}
		}
	fi
fi

FILE=${URL##*/}
EXTENSION=${URL##*.}
UNZIP_DIR=${FILE/.$EXTENSION/}
export UNZIP_DIR

if [[ ! -f ${FILE} ]]; then
	if [[ "$(find . -type f | wc -l)" != 1 ]]; then
		editTGmsg "Can't seem to find downloaded file!"
		exit 1
	else
		FILE="$(find . -type f)"
	fi
fi

PARTITIONS="system vendor cust odm oem factory product modem xrom systemex system_ext system_other oppo_product opproduct reserve india my_preload my_odm my_stock my_operator my_country my_product my_company my_engineering my_heytap"

if [[ ! -d "${HOME}/extract-dtb" ]]; then
	git clone -q https://github.com/PabloCastellano/extract-dtb ~/extract-dtb
else
	git -C ~/extract-dtb pull
fi

if [[ ! -d "${HOME}/Firmware_extractor" ]]; then
	git clone -q https://github.com/AndroidDumps/Firmware_extractor ~/Firmware_extractor
else
	git -C ~/Firmware_extractor pull
fi

if [[ ! -d "${HOME}/mkbootimg_tools" ]]; then
	git clone -q https://github.com/xiaolu/mkbootimg_tools ~/mkbootimg_tools
else
	git -C ~/mkbootimg_tools pull
fi

if [[ ! -d "${HOME}/vmlinux-to-elf" ]]; then
	git clone -q https://github.com/marin-m/vmlinux-to-elf ~/vmlinux-to-elf
else
	git -C ~/vmlinux-to-elf pull
fi

bash ~/Firmware_extractor/extractor.sh "${FILE}" "${PWD}" || (
	editTGmsg "Extraction failed!"
	exit 1
)

rm -fv "$FILE"

# Extract the images
for p in $PARTITIONS; do
	if [ -f "$p.img" ]; then
		mkdir "$p" || rm -rf "${p:?}"/*
		7z x "$p".img -y -o"$p"/ || {
			sudo mount -o loop "$p".img "$p"
			mkdir "${p}_"
			sudo cp -rf "${p}/*" "${p}_"
			sudo umount "${p}"
			sudo mv "${p}_" "${p}"
		}
		rm -fv "$p".img
	fi
done

# Bail out right now if no system build.prop
ls system/build*.prop 2>/dev/null || ls system/system/build*.prop 2>/dev/null || {
	editTGmsg "No system build*.prop found, pushing cancelled!"
	exit 1
}

if [[ ! -f "boot.img" ]]; then
	x=$(find . -type f -name "boot.img")
	if [[ -n $x ]]; then
		mv -v "$x" boot.img
	else
		echo "boot.img not found!"
	fi
fi

if [[ ! -f "dtbo.img" ]]; then
	x=$(find . -type f -name "dtbo.img")
	if [[ -n $x ]]; then
		mv -v "$x" dtbo.img
	else
		echo "dtbo.img not found!"
	fi
fi

# Extract bootimage and dtbo
if [[ -f "boot.img" ]]; then
	mkdir -v bootdts
	~/mkbootimg_tools/mkboot ./boot.img ./bootimg >/dev/null
	python3 ~/extract-dtb/extract-dtb.py ./boot.img -o ./bootimg >/dev/null
	find bootimg/ -name '*.dtb' -type f -exec dtc -I dtb -O dts {} -o bootdts/"$(echo {} | sed 's/\.dtb/.dts/')" \; >/dev/null 2>&1
	# Extract ikconfig
	curl -s https://raw.githubusercontent.com/torvalds/linux/master/scripts/extract-ikconfig | bash -s boot.img >ikconfig
	# Kallsyms
	python3 ~/vmlinux-to-elf/vmlinux_to_elf/kallsyms_finder.py boot.img >kallsyms.txt
	# ELF
	python3 ~/vmlinux-to-elf/vmlinux_to_elf/main.py boot.img boot.elf
fi
if [[ -f "dtbo.img" ]]; then
	mkdir -v dtbodts
	python3 ~/extract-dtb/extract-dtb.py ./dtbo.img -o ./dtbo >/dev/null
	find dtbo/ -name '*.dtb' -type f -exec dtc -I dtb -O dts {} -o dtbodts/"$(echo {} | sed 's/\.dtb/.dts/')" \; >/dev/null 2>&1
fi

# Oppo/Realme devices have some images in a euclid folder in their vendor, extract those for props
if [[ -d "vendor/euclid" ]]; then
	pushd vendor/euclid || exit 1
	for f in *.img; do
		[[ -f $f ]] || continue
		7z x "$f" -o"${f/.img/}"
		rm -fv "$f"
	done
	popd || exit 1
fi

# board-info.txt
find ./modem -type f -exec strings {} \; | grep "QC_IMAGE_VERSION_STRING=MPSS." | sed "s|QC_IMAGE_VERSION_STRING=MPSS.||g" | cut -c 4- | sed -e 's/^/require version-baseband=/' >>./board-info.txt
find ./tz* -type f -exec strings {} \; | grep "QC_IMAGE_VERSION_STRING" | sed "s|QC_IMAGE_VERSION_STRING|require version-trustzone|g" >>./board-info.txt
if [ -f ./vendor/build.prop ]; then
	strings ./vendor/build.prop | grep "ro.vendor.build.date.utc" | sed "s|ro.vendor.build.date.utc|require version-vendor|g" >>./board-info.txt
fi
sort -u -o ./board-info.txt ./board-info.txt

# Prop extraction
flavor=$(grep -m1 -oP "(?<=^ro.build.flavor=).*" -hs {vendor,system,system/system}/build.prop)
[[ -z ${flavor} ]] && flavor=$(grep -m1 -oP "(?<=^ro.vendor.build.flavor=).*" -hs vendor/build*.prop)
[[ -z ${flavor} ]] && flavor=$(grep -m1 -oP "(?<=^ro.build.flavor=).*" -hs {vendor,system,system/system}/build*.prop)
[[ -z ${flavor} ]] && flavor=$(grep -m1 -oP "(?<=^ro.system.build.flavor=).*" -hs {system,system/system}/build*.prop)
[[ -z ${flavor} ]] && flavor=$(grep -m1 -oP "(?<=^ro.build.type=).*" -hs {system,system/system}/build*.prop)
release=$(grep -m1 -oP "(?<=^ro.build.version.release=).*" -hs {vendor,system,system/system}/build*.prop)
[[ -z ${release} ]] && release=$(grep -m1 -oP "(?<=^ro.vendor.build.version.release=).*" -hs vendor/build*.prop)
[[ -z ${release} ]] && release=$(grep -m1 -oP "(?<=^ro.system.build.version.release=).*" -hs {system,system/system}/build*.prop)
id=$(grep -m1 -oP "(?<=^ro.build.id=).*" -hs {vendor,system,system/system}/build*.prop)
[[ -z ${id} ]] && id=$(grep -m1 -oP "(?<=^ro.vendor.build.id=).*" -hs vendor/build*.prop)
[[ -z ${id} ]] && id=$(grep -m1 -oP "(?<=^ro.system.build.id=).*" -hs {system,system/system}/build*.prop)
incremental=$(grep -m1 -oP "(?<=^ro.build.version.incremental=).*" -hs {vendor,system,system/system}/build*.prop | head -1)
[[ -z ${incremental} ]] && incremental=$(grep -m1 -oP "(?<=^ro.vendor.build.version.incremental=).*" -hs vendor/build*.prop)
[[ -z ${incremental} ]] && incremental=$(grep -m1 -oP "(?<=^ro.system.build.version.incremental=).*" -hs {system,system/system}/build*.prop | head -1)
[[ -z ${incremental} ]] && incremental=$(grep -m1 -oP "(?<=^ro.build.version.incremental=).*" -hs my_product/build*.prop)
[[ -z ${incremental} ]] && incremental=$(grep -m1 -oP "(?<=^ro.system.build.version.incremental=).*" -hs my_product/build*.prop)
[[ -z ${incremental} ]] && incremental=$(grep -m1 -oP "(?<=^ro.vendor.build.version.incremental=).*" -hs my_product/build*.prop)
tags=$(grep -m1 -oP "(?<=^ro.build.tags=).*" -hs {vendor,system,system/system}/build*.prop)
[[ -z ${tags} ]] && tags=$(grep -m1 -oP "(?<=^ro.vendor.build.tags=).*" -hs vendor/build*.prop)
[[ -z ${tags} ]] && tags=$(grep -m1 -oP "(?<=^ro.system.build.tags=).*" -hs {system,system/system}/build*.prop)
platform=$(grep -m1 -oP "(?<=^ro.board.platform=).*" -hs {vendor,system,system/system}/build*.prop | head -1)
[[ -z ${platform} ]] && platform=$(grep -m1 -oP "(?<=^ro.vendor.board.platform=).*" -hs vendor/build*.prop)
[[ -z ${platform} ]] && platform=$(grep -m1 -oP rg"(?<=^ro.system.board.platform=).*" -hs {system,system/system}/build*.prop)
manufacturer=$(grep -m1 -oP "(?<=^ro.product.manufacturer=).*" -hs {vendor,system,system/system}/build*.prop | head -1)
[[ -z ${manufacturer} ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.vendor.product.manufacturer=).*" -hs vendor/build*.prop)
[[ -z ${manufacturer} ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.vendor.manufacturer=).*" -hs vendor/build*.prop)
[[ -z ${manufacturer} ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.system.product.manufacturer=).*" -hs {system,system/system}/build*.prop)
[[ -z ${manufacturer} ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.system.manufacturer=).*" -hs {system,system/system}/build*.prop)
[[ -z ${manufacturer} ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.odm.manufacturer=).*" -hs vendor/odm/etc/build*.prop)
[[ -z ${manufacturer} ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.manufacturer=).*" -hs {oppo_product,my_product}/build*.prop | head -1)
[[ -z ${manufacturer} ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.manufacturer=).*" -hs vendor/euclid/*/build.prop)
[[ -z ${manufacturer} ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.system.product.manufacturer=).*" -hs vendor/euclid/*/build.prop)
[[ -z ${manufacturer} ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.product.manufacturer=).*" -hs vendor/euclid/product/build*.prop)
fingerprint=$(grep -m1 -oP "(?<=^ro.vendor.build.fingerprint=).*" -hs vendor/build*.prop)
[[ -z ${fingerprint} ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.build.fingerprint=).*" -hs {system,system/system}/build*.prop)
[[ -z ${fingerprint} ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.product.build.fingerprint=).*" -hs product/build*.prop)
[[ -z ${fingerprint} ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.system.build.fingerprint=).*" -hs {system,system/system}/build*.prop)
[[ -z ${fingerprint} ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.build.fingerprint=).*" -hs my_product/build.prop)
[[ -z ${fingerprint} ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.system.build.fingerprint=).*" -hs my_product/build.prop)
[[ -z ${fingerprint} ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.vendor.build.fingerprint=).*" -hs my_product/build.prop)
brand=$(grep -m1 -oP "(?<=^ro.product.brand=).*" -hs {vendor,system,system/system}/build*.prop | head -1)
[[ -z ${brand} ]] && brand=$(grep -m1 -oP "(?<=^ro.product.vendor.brand=).*" -hs vendor/build*.prop | head -1)
[[ -z ${brand} ]] && brand=$(grep -m1 -oP "(?<=^ro.vendor.product.brand=).*" -hs vendor/build*.prop | head -1)
[[ -z ${brand} ]] && brand=$(grep -m1 -oP "(?<=^ro.product.system.brand=).*" -hs {system,system/system}/build*.prop | head -1)
[[ -z ${brand} || ${brand} == "OPPO" ]] && brand=$(grep -m1 -oP "(?<=^ro.product.system.brand=).*" -hs vendor/euclid/*/build.prop | head -1)
[[ -z ${brand} ]] && brand=$(grep -m1 -oP "(?<=^ro.product.product.brand=).*" -hs vendor/euclid/product/build*.prop)
[[ -z ${brand} ]] && brand=$(grep -m1 -oP "(?<=^ro.product.odm.brand=).*" -hs vendor/odm/etc/build*.prop)
[[ -z ${brand} ]] && brand=$(grep -m1 -oP "(?<=^ro.product.brand=).*" -hs {oppo_product,my_product}/build*.prop | head -1)
[[ -z ${brand} ]] && brand=$(echo "$fingerprint" | cut -d / -f1)
codename=$(grep -m1 -oP "(?<=^ro.product.device=).*" -hs {vendor,system,system/system}/build*.prop | head -1)
[[ -z ${codename} ]] && codename=$(grep -m1 -oP "(?<=^ro.product.vendor.device=).*" -hs vendor/build*.prop | head -1)
[[ -z ${codename} ]] && codename=$(grep -m1 -oP "(?<=^ro.vendor.product.device=).*" -hs vendor/build*.prop | head -1)
[[ -z ${codename} ]] && codename=$(grep -m1 -oP "(?<=^ro.product.system.device=).*" -hs {system,system/system}/build*.prop | head -1)
[[ -z ${codename} ]] && codename=$(grep -m1 -oP "(?<=^ro.product.system.device=).*" -hs vendor/euclid/*/build.prop | head -1)
[[ -z ${codename} ]] && codename=$(grep -m1 -oP "(?<=^ro.product.product.device=).*" -hs vendor/euclid/*/build.prop | head -1)
[[ -z ${codename} ]] && codename=$(grep -m1 -oP "(?<=^ro.product.product.model=).*" -hs vendor/euclid/*/build.prop | head -1)
[[ -z ${codename} ]] && codename=$(grep -m1 -oP "(?<=^ro.product.device=).*" -hs {oppo_product,my_product}/build*.prop | head -1)
[[ -z ${codename} ]] && codename=$(grep -m1 -oP "(?<=^ro.product.product.device=).*" -hs oppo_product/build*.prop)
[[ -z ${codename} ]] && codename=$(grep -m1 -oP "(?<=^ro.product.system.device=).*" -hs my_product/build*.prop)
[[ -z ${codename} ]] && codename=$(grep -m1 -oP "(?<=^ro.product.vendor.device=).*" -hs my_product/build*.prop)
[[ -z ${codename} ]] && codename=$(grep -m1 -oP "(?<=^ro.build.fota.version=).*" -hs {system,system/system}/build*.prop | cut -d - -f1 | head -1)
[[ -z ${codename} ]] && codename=$(echo "$fingerprint" | cut -d / -f3 | cut -d : -f1)
description=$(grep -m1 -oP "(?<=^ro.build.description=).*" -hs {system,system/system}/build.prop)
[[ -z ${description} ]] && description=$(grep -m1 -oP "(?<=^ro.build.description=).*" -hs {system,system/system}/build*.prop)
[[ -z ${description} ]] && description=$(grep -m1 -oP "(?<=^ro.vendor.build.description=).*" -hs vendor/build.prop)
[[ -z ${description} ]] && description=$(grep -m1 -oP "(?<=^ro.vendor.build.description=).*" -hs vendor/build*.prop)
[[ -z ${description} ]] && description=$(grep -m1 -oP "(?<=^ro.product.build.description=).*" -hs product/build.prop)
[[ -z ${description} ]] && description=$(grep -m1 -oP "(?<=^ro.product.build.description=).*" -hs product/build*.prop)
[[ -z ${description} ]] && description=$(grep -m1 -oP "(?<=^ro.system.build.description=).*" -hs {system,system/system}/build*.prop)
[[ -z ${description} ]] && description="$flavor $release $id $incremental $tags"
is_ab=$(grep -m1 -oP "(?<=^ro.build.ab_update=).*" -hs {system,system/system,vendor}/build*.prop)
[[ -z ${is_ab} ]] && is_ab="false"
branch=$(grep ro.build.version.ota oppo_product/build.prop | cut -d'=' -f2)
[[ -z ${branch} ]] && branch=$(echo "$description" | tr ' ' '-')
repo_subgroup=$(echo "$brand" | tr '[:upper:]' '[:lower:]')
[[ -z $repo_subgroup ]] && repo_subgroup=$(echo "$manufacturer" | tr '[:upper:]' '[:lower:]')
repo_name=$(echo "$codename" | tr '[:upper:]' '[:lower:]')
repo="$repo_subgroup/$repo_name"
platform=$(echo "$platform" | tr '[:upper:]' '[:lower:]' | tr -dc '[:print:]' | tr '_' '-' | cut -c 1-35)
top_codename=$(echo "$codename" | tr '[:upper:]' '[:lower:]' | tr -dc '[:print:]' | tr '_' '-' | cut -c 1-35)
manufacturer=$(echo "$manufacturer" | tr '[:upper:]' '[:lower:]' | tr -dc '[:print:]' | tr '_' '-' | cut -c 1-35)

printf "\nflavor: %s\nrelease: %s\nid: %s\nincremental: %s\ntags: %s\nfingerprint: %s\nbrand: %s\ncodename: %s\ndescription: %s\nbranch: %s\nrepo: %s\nmanufacturer: %s\nplatform: %s\ntop_codename: %s\nis_ab: %s\n" "$flavor" "$release" "$id" "$incremental" "$tags" "$fingerprint" "$brand" "$codename" "$description" "$branch" "$repo" "$manufacturer" "$platform" "$top_codename" "$is_ab"

if [[ $is_ab == true ]]; then
	twrpimg=boot.img
else
	twrpimg=recovery.img
fi

if [[ -f $twrpimg ]]; then
	echo "Detected $twrpimg! Generating twrp device tree"
	if python3 -m twrpdtgen "$twrpimg" --output ./twrp-device-tree -v --no-git; then
		if [[ ! -f "working/twrp-device-tree/README.md" ]]; then
			curl https://raw.githubusercontent.com/wiki/SebaUbuntu/TWRP-device-tree-generator/4.-Build-TWRP-from-source.md >twrp-device-tree/README.md
		fi
	else
		echo "Failed to generate twrp tree!"
	fi
else
	echo "Failed to find $twrpimg!"
fi

# Fix permissions
sudo chown "$(whoami)" ./* -R
sudo chmod -R u+rwX ./*

# Generate all_files.txt
find . -type f -printf '%P\n' | sort | grep -v ".git/" >./all_files.txt
git config --global user.name "SamarV-121"
git config --global user.email "samarvispute121@gmail.com"

gpush() {
	find . -size +97M -printf '%P\n' -o -name '*sensetime*' -printf '%P\n' -o -iname '*Megvii*' -printf '%P\n' -o -name '*.lic' -printf '%P\n' -o -name '*zookhrs*' -printf '%P\n' -printf '%P\n' -o -name 'extract_and_push.sh' >.gitignore
	editTGmsg "Dumped, now Committing and pushing"
	git add . ':!system/system/app' ':!system/system/priv-app'
	git commit -m "Add $branch"
	[[ $BRANCH ]] && branch=$BRANCH
	git push "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}" "$branch" || {
		editTGmsg "Pushing failed!"
		echo "Pushing failed!"
		exit 1
	}
	git add system/system/app system/system/priv-app
	git commit -m "Add leftover apps for $branch"
	git push "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}" "$branch" || {
		editTGmsg "Pushing failed!"
		echo "Pushing failed!"
		exit 1
	}
}

# Add, commit, and push after filtering out certain files
if [ "$BRANCH" ]; then
	git clone --depth=1 "${GITHUB_SERVER_URL}"/"${GITHUB_REPOSITORY}" -b "${BRANCH}" ../"${BRANCH}"
	cp -rf -- * ../"${BRANCH}"
	cd ../"${BRANCH}" || exit
	gpush
else
	git init
	git checkout -b "$branch"
	gpush
fi

# Send message to Telegram group
editTGmsg "Pushed <a href=\"${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/tree/$branch\">$description</a>"
