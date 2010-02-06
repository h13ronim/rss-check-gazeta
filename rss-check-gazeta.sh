#!/bin/bash

cd /home/daan/rss/gazetapl-czwa/

FILE="0,35271.html"
rm $FILE
wget http://miasta.gazeta.pl/czestochowa/$FILE

CALOSC=`wc -l $FILE | awk '{ print $1 }'`
BLOCK_START=`cat $FILE | grep -n jt=Aktualno¶ci | awk 'BEGIN {FS=":"} {print $1 }'`
BLOCK_END=`cat $FILE | grep -n /art/921/j921741.jsp | awk 'BEGIN {FS=":"} {print $1 }'`

tail -n `expr $CALOSC - $BLOCK_START - 5` $FILE | head -n `expr $BLOCK_END - $BLOCK_START - 25` > news.html

echo "<rss version=\"2.0\">
	<channel>
	<title>Gazeta.pl :: Czêstochowa :: Aktualno¶ci</title>
	<link>http://miasta.gazeta.pl/czestochowa/$FILE</link>
	<description>Gazeta.pl :: Czêstochowa :: Aktualno¶ci</description>
	<language>pl</language>		
	<ttl>90</ttl>" > news.xml

sed -e 's/<a class=c1n href="/<item>\n<guid>/g' -e 's/.html"><b>/.html<\/guid>\n<title>/g' \
	-e 's/<\/b><\/a>$/<\/title>/g' \
	-e 's/<br class="br6"><a class=a1n href="http:\/\/miasta.gazeta.pl\/czestochowa\/.*.html">/<description>/g' \
	-e 's/<\/a>&nbsp;<span class="c2n" style="font: 10px Tahoma,Verdana;">.*$/<\/description>\n<\/item>/g' \
	-e '/<img class="brd" src="http:\/\/bi.gazeta.pl\/im\/.*\/.*.jpg" border=1 align=right>/d' \
	-e '/^$/d' \
	news.html >> news.xml

echo "	</channel>
</rss>" >> news.xml

iconv -f iso-8859-2 -t utf-8 -o /var/www/rz.wsz.edu.pl/htdocs/rss/gazetapl-czwa.xml news.xml

