#!/bin/bash

# htmlをcurlで取得
curl http://kyotei.sakura.ne.jp/kako.html > ./kako.html

# pupでjson化
cat ./kako.html | pup "[width="770"]" | pup "font json{}" | jq .[].text > filtered.json

# データ整形のループ
nrow=``  # ファイルの行数を取得
    for i in `seq 1 ${nrow}`
    do
        text1=``  # sedでi行のテキストを格納
        text2=``  # sedでi+1行のテキストを格納
        if [ ${text1} == "null" ] then
            if [ ${text2} == "null" ] then
                # 別のファイル("./number.txt")にNA挿入すべき行の番号を追記
            fi
        fi
    done

# 方針だて
# number.txtもRに読み込んで、R内部でnumber.txtを処理すること(別に教えた通り)


# ========
# 宿題
# ========
# 1. filtered.jsonが生成されることを確認せよ
# 2. filtered.jsonに含まれている未成立の行を、適切な処理をすることで、10個のレースのオッズと人気をcsvにまで整形せよ。
# ヒント: 上のループと、csvに整形するときにRを使用するといいと思う
# 注意: curlはネット用接続。jq, pupを入れる必要あり。


    # 着順のデータ整形

    # オッズのデータ整形

# Rに読み込み、データ型を調整

# 出力
