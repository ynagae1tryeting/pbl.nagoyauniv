
getTweetFromUsername <- function(names, number, sleep){
    # タイムラインの取得
    for(user in names){
        print(user)
        # タイムラインから3000件取得
        print(paste(">> Read TimeLine from by @", user, sep=""))
        UserTimeLines <- userTimeline(user, n=number)
        print("read TimeLine")
        # Listをdata.frameに変換
        x <- twListToDF(UserTimeLines)
        print(length(x))
        # CSVファイルで書き出し
        filename <- paste(user,".csv",sep="")
        write.csv(
            x,
            filename,
            quote=TRUE,
            row.names=FALSE,
            append=FALSE
        )
        print("saved csv file, now go to sleep for a while")
        # 連続でダウンロードして、負荷をかけないように次処理まで2分待つ
        Sys.sleep(sleep)
    }
}


cleanText <- function(df){
    # === ステップ2: ビッグデータ分析用のテキスト抽出・クレンズ
    df_tw <- df[complete.cases(df$text),] # text列にNAが入っている列を除外
    df_tw$text <- iconv(df_tw$text, "latin1", "ASCII", sub="") # 文字コードの変換処理
    df_tw$text <- gsub("<.*?>","",df_tw$text) # 絵文字などの特殊な文字の削除処理

    length(grep("&amp;", df_tw$text))     # HTML特殊文字の抽出
    length(grep("&amp;amp;", df_tw$text)) # XML特殊文字の抽出
    length(grep("&quot", df_tw$text)) # XML特殊文字の抽出
    length(grep("&lt", df_tw$text)) # XML特殊文字の抽出
    length(grep("&gt", df_tw$text)) # XML特殊文字の抽出

    df_tw$text <- gsub("&amp;","",df_tw$text) # HTML特殊文字の削除
    df_tw$text <- gsub("[ ¥t]{2,}"," ",df_tw$text) # タブ文字の削除
    df_tw$created <- as.POSIXct(df_tw$created, tz="EST") # タイムゾーンの設定("EST=米国東部時間")
    
    # CSVファイルの書き出し
    write.csv(
        df_tw,
        paste("./",user,"_cleansed.csv",sep=""),
        quote=TRUE,
        row.names=FALSE,
        append=FALSE
    )
    print("save csv file")
}

analyzeSentiment <- function(user, num.cluster, bootstrap){
    df_tw <- read.csv(paste("./",user,"_cleansed.csv",sep=""))
    df_tw <- data.frame(df_tw)

    # ヘッドラインの行のみの抽出
    df_tw$text <- as.vector(df_tw$text)

    # お気に入り+リツイート
    interest <- df_tw$favoriteCount + df_tw$retweetCount

    # 感情分析 
    mySentiment <- get_sentiment(df_tw$text, method="syuzhet") # 感情辞書との突き合わせ

    # データセット作成
    # 感情分析結果、お気に入り数とリツイートの数の合計を関心度とする。
    df <- cbind(
        Sentiment=mySentiment,
        Interest=interest
        )

    # 機械的にクラスターを決定するため、GAP統計量を計算する
    gap_stat <- clusGap(
        df,
        FUN=kmeans,
        K.max=num.cluster,
        B=bootstrap
        )
    plot(gap_stat)

    # 最大のGAP統計量を抽出
    km.res <- grep(
        max(gap_stat$Tab[,3]),
        gap_stat$Tab[,3]
    )

    # "gap"列の要素数を取得
    n <- length(gap_stat$Tab[,3])

    # 二番目に大きいGAP統計量からクラスタ数を抽出
    sec <- sort(gap_stat$Tab[,3])[n-1]
    sec <- grep(sec, gap_stat$Tab[,3])

    # 三番目に大きいGAP統計量からクラスタ数を抽出
    thi <- sort(gap_stat$Tab[,3][n-2])
    thi <- grep(thi, gap_stat$Tab[,3])

    # 最大のGAP統計量時にクラスタ数が"1"または"10"
    if(km.res == 1 || km.res == 10){
        # 二番目に大きいGAP統計量時にクラスタが"1"または"10"
        if(sec == 1 || sec == 10){
            # 三番目に大きいGAP統計量からクラスタを代入
            km.res <- thi
        } else{
            # 二番目に大きいGAP統計量からクラスタ数を代入
            km.res <- sec
        }
    }

    # kmeansで計算
    km.res <- kmeans(df, km.res)

    # 計算結果を可視化
    df_plot <- fviz_cluster(
        km.res,
        data = df,
        frame.type = "norm") 
        # + theme_minimal(),
    
    # ビットマップにして保存
    filename <- paste(user, "_cluster.png",sep="")
    png(filename=filename)
    plot(df_plot)
    dev.off()

    # CSVファイルの書き出し
    write.csv(
        senti,
        paste("./",user,"_senti.csv",sep=""),
        quote=FALSE,
        row.names=FALSE,
        append=FALSE
    )
    print("save csv file")
}
