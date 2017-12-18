# ----------------------
# 第5回目参考コード
# 自然言語処理におけるテキストデータの取得と前処理
# ----------------------

# ステップ1: ビッグデータ分析用のテキスト抽出
library(twitteR)

# twitterアプリケーションの管理画面から取得(これは長江が)
source("../../config_pbl5.R")
source("./functions.R")   # 自分で設定した関数

# httr_oauth_chcheを取得
options(httr_oauth_chche = TRUE)

# 認証情報の取得
setup_twitter_oauth(consumerKey,
                    consumerSecret,
                    accessToken,
                    accessSecret)

# ステップ2: ユーザー名を指定して、ユーザー名のタイムラインからデータを取得する

# ユーザー名一覧
usernames <- c("WSJmarkets",
               "FXstreetNews",
               "IBDinvestors",
               "ForexLive",
               "USATODAY",
               "washingtonpost")

getTweetFromUsername(usernames, 400, 20)

# ステップ3: 不正な文字を削除する
for(user in usernames){
    df <- read.csv(paste("./",user,".csv",sep=""))
    cleanText(df)
}

# === ステップ3: テキストに感情の点数をつける

library("syuzhet")   # 感情分析用ライブラリ(英語)
library("cluster")   # クラスタリング用ライブラリ
library("factoextra")   # クラスタを可視化するやつ

for(user in usernames){
    analyzeSentiment(user, 5, 50)
}

