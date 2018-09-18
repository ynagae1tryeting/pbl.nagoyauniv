#!bin/bash

# curlによるデータ取得
curl http://www.jz-tamago.co.jp/souba/quote/2018-03-08 | pup 'table td json{}' | jq .

# jqによる整形
curl http://www.jz-tamago.co.jp/souba/quote/2018-03-08 | pup 'table td json{}' | jq .

# tableのタイトルのみ抽出
curl http://www.jz-tamago.co.jp/souba/quote/2018-03-08 | pup 'table td p json{}' | jq .[].text

# 東京
p1=`curl http://www.jz-tamago.co.jp/souba/quote/2018-03-08 | pup 'table td[class="high"] json{}' | jq .[].text | sed -n -e 1,6p`

# 日付で選択しているので、日付を${date}変数に格納して、実行してみよう。

date="2018-03-08"
p1=`curl http://www.jz-tamago.co.jp/souba/quote/${date} | pup 'table td[class="high"] json{}' | jq .[].text | sed -n -e 1,6p`

mkdir ./data
touch ./data/eggprices.txt

echo "date, V1" > ./data/eggprices.txt
echo "${date}, ${p1}" >> ./data/eggprices.txt

# 終わり。あとはforで工夫して計算してみること。