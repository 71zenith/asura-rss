#!/bin/sh
base_url="https://www.mangapill.com/chapters"

oldfile="$(cat mangapill.xml)"

time=$(date -R)

! test -s mangapill.xml && printf '<?xml version="1.0" encoding="UTF-8" ?>\n<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">\n\n<channel>\n<title>Mangapill - RSS Feed</title>\n<link>https://github.com/71zenith/asura-rss</link>\n<description>A simple RSS feed for mangapill!</description>\n<atom:link href="https://raw.githubusercontent.com/71zenith/asura-rss/master/mangapill.xml" rel="self" type="application/rss+xml" />\n' >mangapill.xml

to_search=$(cat manga)

data=$(curl "$base_url" | sed '1,/Recently Released Chapters/d ; /These shortcuts/,$d' | tr -d '\n' | sed 's/<div class="mt-1.5 text-xs text-secondary">/\n/g' | sed -nE 's|.*href="([^"]+)".*alt="([^"]+)".*|\1\t\2|p')
sed '/<\/channel>/d; /<\/rss>/d' -i mangapill.xml
for i in $to_search; do
	match=$(printf "%s\n" "$data" | grep "${i}-chapter")
	if [ -n "$match" ]; then
		link="https://mangapill.com$(printf "%s\n" "$match" | cut -f1)"
		title=$(printf "%s\n" "$match" | cut -f2)
		rss=$(printf '\n<item>\n<title>%s</title>\n<link>%s</link>\n<description>A simple RSS feed for mangapill!</description>\n<pubDate>%s</pubDate>\n</item>\n' "$title" "$link" "${time}")
		if ! printf "%s\n" "$oldfile" | grep -q "$title"; then
			printf "%s\n" "$rss" >>mangapill.xml
		fi
	fi
done
printf "</channel>\n</rss>" >>mangapill.xml
