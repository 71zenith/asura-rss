#!/bin/sh
base_url="https://asuratoon.com"

oldfile="$(cat asura.xml)"

time=$(date -R)

! test -s asura.xml && printf '<?xml version="1.0" encoding="UTF-8" ?>\n<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">\n\n<channel>\n<title>AsuraScans (Scumbags) - RSS Feed</title>\n<link>https://github.com/71zenith/asura-rss</link>\n<description>A simple RSS feed for asurascans!</description>\n<atom:link href="https://raw.githubusercontent.com/71zenith/asura-rss/master/asura.xml" rel="self" type="application/rss+xml" />\n' >asura.xml

to_search=$(cat manhwa)

data=$(curl "$base_url" | sed '1,/Latest Update/d ; /Popular/,$d' | tr -d '\n' | sed 's/<\/div><div class="utao styletwo">/\n/g' | sed -nE 's|.*img src="([^"]+)".*<h4>([^>]+)</h4></a><ul class="([^"]+)"><li><a href="([^"]+)">([^<]+)<.*|\1\t\2\t\4\t\5|p')
sed '/<\/channel>/d; /<\/rss>/d' -i asura.xml
for i in $to_search; do
	match=$(printf "%s\n" "$data" | grep "${i}-chapter")
	if [ -n "$match" ]; then
		thumb=$(printf "%s\n" "$match" | cut -f1)
		title=$(printf "%s\n" "$match" | cut -f2)
		link=$(printf "%s\n" "$match" | cut -f3)
		chap=$(printf "%s\n" "$match" | cut -f4)
		rss=$(printf '\n<item>\n<title>%s</title>\n<link>%s</link>\n<description><![CDATA[\n    <p><img src="%s" alt="A simple RSS feed for asura!"></p>\n  ]]></description>\n<pubDate>%s</pubDate>\n</item>\n' "$title $chap" "$link" "$thumb" "${time}")
		if ! printf "%s\n" "$oldfile" | grep -q "$title $chap"; then
			printf "%s\n" "$rss" >>asura.xml
		fi
	fi
done
printf "</channel>\n</rss>" >>asura.xml
