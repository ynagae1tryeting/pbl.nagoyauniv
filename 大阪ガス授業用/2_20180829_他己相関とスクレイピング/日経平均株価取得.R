curl -s https://info.finance.yahoo.co.jp/history/?code=998407.O | pup 'table json{}' | jq .


# ========================================
# 名称: Peppermint
# 用途: 外部データを集めてまとめるボット！
# 入力: 
# 出力: 
# ========================================

library("XML")

library(TryetingTools)
hello()
# --- 出入力のデータのディレクトリ設定
dataInputPath  = "~/Dropbox/開発用/100_data/100_AIセミナー/input"
dataOutputPath = "~/Dropbox/開発用/100_data/100_AIセミナー/output"

# --- ウェブサイト「日経平均プロフィル 日経の指数情報サイト」で公開されている日経平均株価の日次データファイルをRに取り込む
address <- "http://indexes.nikkei.co.jp/nkave/historical/nikkei_stock_average_daily_jp.csv"
nikkei <- read.csv(file=url(address), header=F, sep=",",skip=1)
colnames(nikkei) <- c("データ日付","終値","始値","高値","安値")

# --- データの冒頭を確認。
head(nikkei)

# --- データの末尾を確認
tail(nikkei,3)

# --- 末尾に文章（注記）が記述されているため、データオブジェクト nikkei から、 856行目を削除
nikkei <- nikkei[-857, ]

# --- データ時系列推移 概形確認（グラフの形）
# --- 各株価時系列データを取り出してオブジェクト化
colnames(nikkei) <- c("date","end", "start", "high", "low")
nikkei <- head(nikkei,-1)
nikkei$date <- as.Date(nikkei$date)

prices <- cbind(nikkei$end, nikkei$start, nikkei$high, nikkei$low)
prices <- data.frame(prices)
colnames(prices) <- c("end", "start", "high", "low")
end_price <- data.frame("end"=prices$end)

end_prices_lead30 <- end_price %>% dplyr::mutate("lead"=lead(end,30))

model <- df2model(end_prices_lead30)




head(prices)

# --- 終値・始値・高値・安値の時間推移をグラフで確認
par(mfrow=c(2,2), new=F)
plot(prices[, 1], type="l", xlab="days from 2011/01/04", ylab="nikkei ave.", col="blue1", main="endprice")
plot(prices[, 2], type="l", xlab="days from 2011/01/04", ylab="nikkei ave.", col="deeppink1", main="startprice")
plot(prices[, 3], type="l", xlab="days from 2011/01/04", ylab="nikkei ave.", col="red1", main="highprice")
plot(prices[, 4], type="l", xlab="days from 2011/01/04", ylab="nikkei ave.", col="green3", main="lowprice")
par(mfrow=c(1,1))

# =============================
# 
# デ ー タ 整 形 ・ 加 工 工 程
# 
# =============================

# 当日値動き幅 / 終値の前日比 / 前々日比 / 2日前比/...7日前比 を算出・追加
close.price <- prices[, 1]

# change:前日比(%) / change.X:X日前比 (%)

# lag()関数を使って、データをずらすために、便宜的に四半期データのts型データに変換（※便宜的に変換しているので、以下のデータのdate列の表記は意味なし）
close.price <- ts(close.price, start=c(2011,01), frequency=4)

change.1 <-((close.price - lag(close.price,-1))/lag(close.price,-1))*100
change.2 <-((close.price - lag(close.price,-2))/lag(close.price,-2))*100
change.3 <-((close.price - lag(close.price,-3))/lag(close.price,-3))*100
change.4 <-((close.price - lag(close.price,-4))/lag(close.price,-4))*100
change.5 <-((close.price - lag(close.price,-5))/lag(close.price,-5))*100
change.6 <-((close.price - lag(close.price,-6))/lag(close.price,-6))*100
change.7 <-((close.price - lag(close.price,-7))/lag(close.price,-7))*100

change.1 <- round(change.1,1)
change.2 <- round(change.2,1)
change.3 <- round(change.3,1)
change.4 <- round(change.4,1)
change.5 <- round(change.5,1)
change.6 <- round(change.6,1)
change.7 <- round(change.7,1)

# 当日値動き幅
change.0 <- round(((end-start)/start)*100,1)

# length(change.1)   836行
# length(change.2)   835行
# length(change.7)   830行

length <- length(change.7) 

volatilities <- data.frame(end.price=end[1:length], change.0=change.0[1:length], change.1=change.1[1:length], change.2=change.2[1:length], change.3=change.3[1:length], change.4=change.4[1:length], change.5=change.5[1:length], change.6=change.6[1:length], change.7=change.7[1:length])

head(volatilities)



# --- 予測
plot(1:nrow(d.test), volatilities.rfp, type="l", col="red")
par(new=T)
plot(1:nrow(d.test), d.test[,2], type="l", col="blue")
par(new=F)
legend("topleft", c("当日 値動き幅（正解）：青", "当日 値動き幅（予測値）：赤"))

# --- 手法:svmRadial

# === data1: START ====

# === data1: END ====


# --- 出力フロー

saveRDS(data1, "data1.dat")
