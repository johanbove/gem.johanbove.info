#!/usr/bin/env bash

# Copyright 2020 nytpu
# https://tildegit.org/nytpu/gemlog.sh
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


# change configuration variables here to suit you
### be sure to also change the header and footer in build_entries! ###
make_globals() {
	global_title="Johan's Gemlog"
	global_description="Short notes and blog posts by Johan Bové."
	global_url="gemini://gem.johanbove.info/gemlog/" # link to base url of gemlog
	global_author="Johan"
	global_author_email="hello@johanbove.info"
	global_author_url="gemini://gem.johanbove.info/" # homepage of author
	global_license="CC BY 4.0"

	gemlog_feed="atom.xml" # filename of the atom feed
	number_of_feed_articles="50" # maximum number of posts added to atom feed
	feed_base_url="gemini://gem.johanbove.info/gemlog/" # base url that the feed is hosted at
	feed_web_url="https://portal.mozz.us/gemini/gem.johanbove.info/gemlog/" # base url that the feed is hosted at on the web

	index="index.gmi" # main page of gemlog, not recommended to change

	use_year_divider=true # separate posts from different years with a heading?

	# these 2 are exclusive, and use_month_divider_nl takes priority if both are set
	use_month_divider_nl=true # separate posts from different months with a newline?
	use_month_divider_hd=false # separate posts from different months with a heading?


	gemlog_sh_link="https://tildegit.org/nytpu/gemlog.sh" # link to the utility, you should change this if you've made substantial non-configuration changes

	# don't change these
	date_format_8601="+%Y-%m-%dT%H:%M:%S%:z" # *formal* ISO-8601 format including time zone
	date_format_8601_timeless="+%Y-%m-%dT12:00:00%:z" # *formal* ISO-8601 format with fixed preset time
	monthnames=( "invalid" "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December" )
}

get_post_title() {
	cat "$1" | perl -lne 's/#{1,3}\s+(.*)/\1/ or next; print; exit'
}

make_atom() {
	echo "Bulding atom feed..."

	atomfile="$gemlog_feed.$RANDOM"
	while [[ -f $atomfile ]]; do atomfile="$gemlog_feed.$RANDOM"; done

	{
		pubdate=$(date "$date_format_8601")
		cat << EOF
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>$global_title</title>
  <subtitle>$global_description</subtitle>
  <link rel='self' href='$feed_base_url$gemlog_feed'/>
  <link rel='alternate' href='$global_url$index'/>
  <updated>$pubdate</updated>
  <author>
    <name>$global_author</name>
    <email>$global_author_email</email>
    <uri>$global_author_url</uri>
  </author>
  <id>$global_url</id>
  <generator uri='$gemlog_sh_link'>gemlog.sh</generator>
  <rights>© $global_author - $global_license</rights>
EOF
		n=0
		while IFS='' read -r i; do
			((n >= $number_of_feed_articles)) && break
			printf "\n  <entry>\n    <title>"
			get_post_title "$i" | tr -d '\n'
			printf "</title>\n    <id>$global_url${i#'./'}</id>\n"
			printf "    <link rel='alternate' href='$global_url${i#'./'}'/>\n    <updated>"
			echo "$i" | perl -ne '/^(\d{4}-\d{2}-\d{2}).*/; print $1' | date "$date_format_8601_timeless" -f - | tr -d '\n'
			# change or remove the <summary></summary> block if you want a different description or no description at all
			printf "</updated>\n    <summary>You need a gemini client to view this post. If you have one installed, here is the link to the post: $global_url${i#'./'}</summary>\n  </entry>\n"

			n=$(( n + 1 ))
		done < <(ls -r [[:digit:]]*.gmi)

		printf '</feed>'
	} 3>&1 >"$atomfile"

	mv "$atomfile" "$gemlog_feed"
	chmod 644 "$gemlog_feed"
}

build_entries() {
	echo "Building index..."

	indexfile="$index.$RANDOM"
	while [[ -f $indexfile ]]; do indexfile="$index.$RANDOM"; done

	{
		# header of the page (above the posts list)
		cat << 'EOF'
# Johan's Gemlog

Short notes and blog posts by Johan Bové.
EOF
		curyear=""
		curmonth=""
		while IFS='' read -r i; do
			post=$(basename $i)
			title=$(get_post_title "$i")
			pubdate=$(echo $i | perl -ne '/^(\d{4}-\d{2}-\d{2}).*/; print $1')

			newcuryear=$(echo $i | perl -ne '/^(\d{4})-\d{2}-\d{2}.*/; print $1')
			newcurmonth=$(echo $i | perl -ne '/^\d{4}-(\d{2})-\d{2}.*/; print $1')
			if [ "$newcuryear" != "$curyear" ] && $use_year_divider; then
				printf "\n\n## $newcuryear\n"
				curyear="$newcuryear"
			fi
			if [ "$newcurmonth" != "$curmonth" ]; then
				if $use_month_divider_nl; then
					printf "\n"
				elif $use_month_divider_hd; then
					printf "\n### ${monthnames[${newcurmonth#0}]}\n\n"
				fi
				curmonth="$newcurmonth"
			fi

			printf "=> $global_url$post $pubdate — $title\n"
		done < <(ls -r [[:digit:]]*.gmi)

		# footer of the page (below the list of posts)
		cat << EOF


──────────────────

=> / go home

=> $feed_base_url$gemlog_feed Atom feed through Gemini
=> $feed_web_url$gemlog_feed Atom feed through HTTPS

=> $gemlog_sh_link Generated with gemlog.sh
EOF
	} 3>&1 >"$indexfile"

	mv "$indexfile" "$index"
	chmod 644 "$index"
}

toot() {
	filename=$(ls -r ./[[:digit:]]*.gmi | head -n 1 | xargs basename)
	title=$(get_post_title "$filename")
	read -r -p "do you want to toot the newest post? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		echo "tooting..."
		# change this if you want the toot to have different content
		printf "new gemlog post: ${title}\n\n${global_url}${filename}\n" | toot post
	fi
}

twt(){
  echo -e "`date +%FT%T%:z`\t$1" >> ~/twtxt.txt
}

twtxt() {
	filename=$(ls -r ./[[:digit:]]*.gmi | head -n 1 | xargs basename)
	title=$(get_post_title "$filename")
	read -r -p "do you want to twtxt the newest post? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		echo "twtxting..."
		# change this if you want the toot to have different content
		#printf "new gemlog post: ${title} - ${global_url}${filename}"
    twt "New gemlog post: [${title}](${global_url}${filename})"
	fi
}

make_globals
make_atom
build_entries
# toot
twtxt
