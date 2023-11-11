#!/bin/sh
base_url="https://asuratoon.com"

oldfile="$(cat asura.xml)"

time=$(date -u +%a,\ %d\ %b\ %Y\ %T\ %Z)

! test -s asura.xml && printf '<?xml version="1.0" encoding="UTF-8" ?>\n<rss version="2.0">\n\n<channel>\n<title>AsuraScans (Scumbags) - RSS Feed</title>\n<link>https://github.com/71zenith/asura-rss</link>\n<description>A simple RSS feed for asurascans!</description>\n' >asura.xml

to_search=$(cat manhwa)

data=$(curl "$base_url" | tr -d '\n' | grep -Eo '<[^"]+"[^>]+><li><a href="[^"]+">Chapter [^>]+' | sed -nE 's|<h4>([^<]+)<.*href="([^"]+).*>([^<]+).*|\1\t\2\t\3|p')
sed '/<\/channel>/d; /<\/rss>/d' -i asura.xml
for i in $to_search; do
	match=$(printf "%s\n" "$data" | grep "${i}-chapter")
	if [ -n "$match" ]; then
		title=$(printf "%s\n" "$match" | cut -f1)
		link=$(printf "%s\n" "$match" | cut -f2)
		chap=$(printf "%s\n" "$match" | cut -f3)
		rss=$(printf '\n<item>\n<title>%s</title>\n<link>%s</link>\n<description>A simple RSS feed for asura!</description>\n<pubDate>%s</pubDate>\n</item>\n' "$title $chap" "$link" "${time}")
		if ! printf "%s\n" "$oldfile" | grep -q "$title $chap"; then
			sed '/<\/channel>/d; /<\/rss>/d' -i asura.xml
			printf "%s\n" "$rss" >>asura.xml
		fi
	fi
done
printf "</channel>\n</rss>" >>asura.xml
