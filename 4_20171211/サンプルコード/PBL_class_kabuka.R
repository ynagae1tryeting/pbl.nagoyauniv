# ----------------------
# 第4回目参考コード
# ----------------------

library("caret")

# embed関数の強化版
# Embed(x=データ, m=lagをとる個数, d=lagの日数)
Embed <- function(x, m, d = 1) {
    n <- length(x) - (m-1)*d
    if(n <= 0){
        stop("Insufficient observations for the requested embedding")
    }else{
        out <- embed(x, m*d+1)
        out <- out[,rev(seq(1, m*d+1, d))]
    }
    return(out)
}


# データを取得する関数。
# 関数の名前は、わかりやすい名前をつけておくこと。
# 1) 何を、どうするのかがはっきりわかる
# 2) 機能がそれ単体で成立する
# code: 証券コード

getStockprices <- function(code){
    d <- read.csv(paste("http://k-db.com/stocks/",code,"-T?download=csv",sep=""), header=F, skip=1)

    colnames(d) <- c("date", "start", "high", "low", "end", "transaction", "totalamount")
    return(d)
}

# デンソー：6902
x <- getStockprices(6902)

# 高値に関して予測モデルを構築する。
# 直近30日分をテスト用にとっておく

d.high <- x$high
d.high.test <- head(d.high, 30)
d.high.train <- tail(x$high, -30)   # 頭の30個を削除


# 学習用データのうち、30日前時点のデータで計算
OBJ <- Embed(d.high.train, 1, 30)[,1]
EXP <- Embed(d.high.train, 1, 30)[,2]   # OBJに対して30日前のデータ

# 3日おきのlagを5回計算して吐き出す...(1)
EXP_3_5 <- Embed(EXP, 5, 3)
DATA_3_5 <- data.frame("OBJ"=head(OBJ,nrow(EXP_3_5)), EXP_3_5)

# 7日おきのlagを5回計算して吐き出す...(2)
EXP_7_5 <- Embed(EXP, 5, 7)
DATA_7_5 <- data.frame("OBJ"=head(OBJ,nrow(EXP_7_5)), EXP_7_5)

# 14日おきのlagを5回計算して吐き出す...(3)
EXP_14_5 <- Embed(EXP, 5, 14)
DATA_14_5 <- data.frame("OBJ"=head(OBJ,nrow(EXP_14_5)), EXP_14_5)


# ---------------------------------------------
# 学習ステップ
# ランダムフォレスト（RandomForestパッケージ）
# ---------------------------------------------

set.seed(0)

model_3_5 <- train(
  OBJ ~ (.)^2, 
  data = DATA_3_5, 
  method = "rf", 
  tuneLength = 4,
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv")
)

model_7_5 <- train(
  OBJ ~ (.)^2, 
  data = DATA_7_5, 
  method = "rf", 
  tuneLength = 4,
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv")
)

model_14_5 <- train(
  OBJ ~ (.)^2, 
  data = DATA_14_5, 
  method = "rf", 
  tuneLength = 4,
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv")
)

# ---------------------------------------------
# 予測・評価ステップ
# R2値... 0.4~あてにならない, 0.6~相関あり, 0.8~ すごく良い, 0.9~かなり良い
# ---------------------------------------------

# model_3_5
#  mtry  RMSE      Rsquared 
#   2    152.2602  0.8063429  <- 
#   8    153.2616  0.7993965
#  14    157.1759  0.7870261
#  21    161.4795  0.7740929

# modlel_7_5
#  mtry  RMSE      Rsquared 
#   2    124.9498  0.9014596  <-
#   8    124.8798  0.8957780
#  14    127.0951  0.8855432
#  21    128.0083  0.8783131

#  mtry  RMSE      Rsquared 
#   2    94.49475  0.9438663
#   8    83.04880  0.9536108 <- 
#  14    83.10119  0.9512539
#  21    87.08574  0.9449796

# 各モデルを用いて、予測をする。
# 先ほど作成したOBJに対して、説明変数と同じ作成条件で予測用説明変数を作成

# 3日おきのlagを5回計算して吐き出す...(1)
EXP_test_3_5 <- Embed(OBJ, 5, 3)
colnames(EXP_test_3_5) <- head(model_3_5$coefnames, ncol(EXP_test_3_5))   # 予測に使用した説明変数のcolnamesに合わせている(エラー回避)

# 7日おきのlagを5回計算して吐き出す...(1)
EXP_test_7_5 <- Embed(OBJ, 5, 7)
colnames(EXP_test_7_5) <- head(model_7_5$coefnames, ncol(EXP_test_7_5))

# 14日おきのlagを5回計算して吐き出す...(1)
EXP_test_14_5 <- Embed(OBJ, 5, 14)
colnames(EXP_test_14_5) <- head(model_14_5$coefnames, ncol(EXP_test_14_5))


# 予測
PRED_3_5 <- predict(model_3_5, EXP_test_3_5)
PRED_7_5 <- predict(model_7_5, EXP_test_7_5)
PRED_14_5 <- predict(model_14_5, EXP_test_14_5)

# 評価
# 平均平方自乗誤差(RMSE)で評価
rmse <- function(true_value, predict_value){
    error <- true_value - predict_value
    sqrt(mean(error^2))
    }

rmse_3_5 <- rmse( d.high.test, head(PRED_3_5,30) )
# 630.5039

rmse_7_5 <- rmse( d.high.test, head(PRED_7_5,30) )
# 649.4118

rmse_14_5 <- rmse( d.high.test, head(PRED_14_5,30) )
# 950.7084

# 図面作成
png("./3_5.png")
plot(rev(PRED_3_5), ylim=c(3000, 7000))
par(new=T)
plot(rev(head(x$high, length(PRED_3_5))), col="red", ylim=c(3000,7000))
dev.off()

# 図面作成
png("./7_5.png")
plot(rev(PRED_7_5), ylim=c(3000, 7000))
par(new=T)
plot(rev(head(x$high, length(PRED_7_5))), col="red", ylim=c(3000,7000))
dev.off()

# 図面作成
png("./14_5.png")
plot(rev(PRED_14_5), ylim=c(3000, 7000))
par(new=T)
plot(rev(head(x$high, length(PRED_14_5))), col="red", ylim=c(3000,7000))
dev.off()


# -----------------------------------
# 変化量を計算して、説明変数に追加してみる
# -----------------------------------

# Embed関数の強化版
# Embed(x=データ, m=lagをとる個数, d=lagの日数)に対して
# さらにラグに対しての変化量を計算して追加する関数
Embed.dif <- function(x, m, d = 1) {
    n <- length(x) - (m-1)*d
    if(n <= 0){
        stop("Insufficient observations for the requested embedding")
    }else{
        out <- embed(x, m*d+1)
        out <- out[,rev(seq(1, m*d+1, d))]
        dif <- (out[,1]-out)/out
        dif <- dif[,-1]
        out <- data.frame(out, dif)
    }
    return(out)
}


# 3日おきのlagを5回計算して吐き出す...(1)
EXP_3_5 <- Embed.dif(EXP, 5, 3)
DATA_3_5 <- data.frame("OBJ"=head(OBJ,nrow(EXP_3_5)), EXP_3_5)

# 7日おきのlagを5回計算して吐き出す...(2)
EXP_7_5 <- Embed.dif(EXP, 5, 7)
DATA_7_5 <- data.frame("OBJ"=head(OBJ,nrow(EXP_7_5)), EXP_7_5)

# 14日おきのlagを5回計算して吐き出す...(3)
EXP_14_5 <- Embed.dif(EXP, 5, 14)
DATA_14_5 <- data.frame("OBJ"=head(OBJ,nrow(EXP_14_5)), EXP_14_5)

# ---------------------------------------------
# 学習ステップ
# ランダムフォレスト（RandomForestパッケージ）
# ---------------------------------------------

set.seed(0)

model_3_5 <- train(
  OBJ ~ (.)^2, 
  data = DATA_3_5, 
  method = "rf", 
  tuneLength = 4,
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv")
)

model_7_5 <- train(
  OBJ ~ (.)^2, 
  data = DATA_7_5, 
  method = "rf", 
  tuneLength = 4,
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv")
)

model_14_5 <- train(
  OBJ ~ (.)^2, 
  data = DATA_14_5, 
  method = "rf", 
  tuneLength = 4,
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv")
)


# ---------------------------------------------
# 予測・評価ステップ
# R2値... 0.4~あてにならない, 0.6~相関あり, 0.8~ すごく良い, 0.9~かなり良い
# ---------------------------------------------

# model_3_5
#  mtry  RMSE      Rsquared 
#   2    175.2081  0.7455582
#  23    165.4473  0.7709502
#  44    168.8897  0.7588324
#  66    172.5217  0.7492875

# modlel_7_5
#  mtry  RMSE      Rsquared 
#   2    139.1929  0.8724739
#  23    138.7394  0.8604496
#  44    142.9703  0.8504199
#  66    142.9714  0.8462730

# model_14_5
#  mtry  RMSE       Rsquared 
#   2    109.08063  0.9336344
#  23     85.40124  0.9563268
#  44     80.54790  0.9588853
#  66     81.95327  0.9535140


# 各モデルを用いて、予測をする。
# 先ほど作成したOBJに対して、説明変数と同じ作成条件で予測用説明変数を作成

# 3日おきのlagを5回計算して吐き出す...(1)
EXP_test_3_5 <- Embed.dif(OBJ, 5, 3)
colnames(EXP_test_3_5) <- head(model_3_5$coefnames, ncol(EXP_test_3_5))   # 予測に使用した説明変数のcolnamesに合わせている(エラー回避)

# 7日おきのlagを5回計算して吐き出す...(1)
EXP_test_7_5 <- Embed.dif(OBJ, 5, 7)
colnames(EXP_test_7_5) <- head(model_7_5$coefnames, ncol(EXP_test_7_5))

# 14日おきのlagを5回計算して吐き出す...(1)
EXP_test_14_5 <- Embed.dif(OBJ, 5, 14)
colnames(EXP_test_14_5) <- head(model_14_5$coefnames, ncol(EXP_test_14_5))


# 予測
PRED_3_5 <- predict(model_3_5, EXP_test_3_5)
PRED_7_5 <- predict(model_7_5, EXP_test_7_5)
PRED_14_5 <- predict(model_14_5, EXP_test_14_5)

# 評価
# 平均平方自乗誤差(RMSE)で評価
rmse_3_5 <- rmse( d.high.test, head(PRED_3_5,30) )
# 633.153

rmse_7_5 <- rmse( d.high.test, head(PRED_7_5,30) )
# 858.251

rmse_14_5 <- rmse( d.high.test, head(PRED_14_5,30) )
# 1066.701

# 図面作成
png("./3_5_rev.png")
plot(rev(PRED_3_5), ylim=c(3000, 7000))
par(new=T)
plot(rev(head(x$high, length(PRED_3_5))), col="red", ylim=c(3000,7000))
dev.off()

# 図面作成
png("./7_5_rev.png")
plot(rev(PRED_7_5), ylim=c(3000, 7000))
par(new=T)
plot(rev(head(x$high, length(PRED_7_5))), col="red", ylim=c(3000,7000))
dev.off()

# 図面作成
png("./14_5_rev.png")
plot(rev(PRED_14_5), ylim=c(3000, 7000))
par(new=T)
plot(rev(head(x$high, length(PRED_14_5))), col="red", ylim=c(3000,7000))
dev.off()

# ----------------------------
# rmse_3_5に対して、さらに説明変数を増やしてみる
# ----------------------------

# 5回分のlagではなく、10回分に増やして説明量を増やしてみる
# 3日おきのlagを5回計算して吐き出す...(1)
EXP_3_10 <- Embed(EXP, 10, 3)
DATA_3_10 <- data.frame("OBJ"=head(OBJ,nrow(EXP_3_10)), EXP_3_10)

model_3_10 <- train(
  OBJ ~ (.)^2, 
  data = DATA_3_10, 
  method = "rf", 
  tuneLength = 4,
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv")
)

# model_3_10
#  mtry  RMSE      Rsquared 
#   2    115.3239  0.9280012
#  23    123.3582  0.9041927
#  44    132.4935  0.8801773
#  66    140.1053  0.8593275

# 3日おきのlagを5回計算して吐き出す...(1)
EXP_test_3_10 <- Embed(OBJ, 10, 3)
colnames(EXP_test_3_10) <- head(model_3_10$coefnames, ncol(EXP_test_3_10))   # 予測に使用した説明変数のcolnamesに合わせている(エラー回避)

# 予測
PRED_3_10 <- predict(model_3_10, EXP_test_3_10)

# 評価
# 平均平方自乗誤差(RMSE)で評価
rmse_3_10 <- rmse( d.high.test, head(PRED_3_10,30) )
# 540.1043

# 図面作成
png("./3_10.png")
plot(rev(PRED_3_10), ylim=c(3000, 7000))
par(new=T)
plot(rev(head(x$high, length(PRED_3_10))), col="red", ylim=c(3000,7000))
dev.off()

# ----------------------------
# difを計算してみる
# ----------------------------

# 5回分のlagではなく、10回分に増やして説明量を増やしてみる
# 3日おきのlagを5回計算して吐き出す...(1)
EXP_3_10 <- Embed.dif(EXP, 10, 3)
DATA_3_10 <- data.frame("OBJ"=head(OBJ,nrow(EXP_3_10)), EXP_3_10)

model_3_10 <- train(
  OBJ ~ (.)^2, 
  data = DATA_3_10, 
  method = "rf", 
  tuneLength = 4,
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv")
)

# model_3_10
#  mtry  RMSE      Rsquared 
#   2    115.3239  0.9280012
#  23    123.3582  0.9041927
#  44    132.4935  0.8801773
#  66    140.1053  0.8593275

# 3日おきのlagを5回計算して吐き出す...(1)
EXP_test_3_10 <- Embed.dif(OBJ, 10, 3)
colnames(EXP_test_3_10) <- head(model_3_10$coefnames, ncol(EXP_test_3_10))   # 予測に使用した説明変数のcolnamesに合わせている(エラー回避)

# 予測
PRED_3_10 <- predict(model_3_10, EXP_test_3_10)

# 評価
# 平均平方自乗誤差(RMSE)で評価
rmse_3_10 <- rmse( d.high.test, head(PRED_3_10,30) )
# 540.1043

# 図面作成
png("./3_10_rev.png")
plot(PRED_3_10, ylim=c(3000, 7000))
par(new=T)
plot(head(x$high, length(PRED_3_10)), col="red", ylim=c(3000,7000))
dev.off()











# ===========================
# 予測機能をまとめた関数作成
# ===========================
# V0=予測したい日数
# V1=lagをとる回数
# V2=lagの日数
# code=計算する株価のコード
# ===========================

makeModel4HighStockprices <- function(V0, V1, V2, code){
    # embed関数の強化版
    # Embed(x=データ, m=lagをとる個数, d=lagの日数)
    Embed <- function(x, m, d = 1) {
        n <- length(x) - (m-1)*d
        if(n <= 0){
            stop("Insufficient observations for the requested embedding")
        }else{
            out <- embed(x, m*d+1)
            out <- out[,rev(seq(1, m*d+1, d))]
        }
        return(out)
    }


# データを取得する関数。
# 関数の名前は、わかりやすい名前をつけておくこと。
# 1) 何を、どうするのかがはっきりわかる
# 2) 機能がそれ単体で成立する
# code: 証券コード

    getStockprices <- function(code){
        d <- read.csv(paste("http://k-db.com/stocks/",code,"-T?download=csv",sep=""), header=F, skip=1)
        colnames(d) <- c("date", "start", "high", "low", "end", "transaction", "totalamount")
        return(d)
    }

# デンソー：6902
    x <- getStockprices(code)

# 高値に関して予測モデルを構築する。
# 直近V0日分をテスト用にとっておく
    d.high <- x$high
    d.high.test <- head(d.high, V0)
    d.high.train <- tail(x$high, -V0)   # 頭のV0個を削除

# 学習用データのうち、V0日前時点のデータで計算
    OBJ <- Embed(d.high.train, 1, V0)[,1]
    EXP <- Embed(d.high.train, 1, V0)[,2]   # OBJに対してV0日前のデータ

# Embed関数の強化版
# Embed(x=データ, m=lagをとる個数, d=lagの日数)に対して
# さらにラグに対しての変化量を計算して追加する関数
Embed.dif <- function(x, m, d = 1) {
    n <- length(x) - (m-1)*d
    if(n <= 0){
        stop("Insufficient observations for the requested embedding")
    }else{
        out <- embed(x, m*d+1)
        out <- out[,rev(seq(1, m*d+1, d))]
        dif <- (out[,1]-out)/out
        dif <- dif[,-1]
        out <- data.frame(out, dif)
    }
    return(out)
}


# 3日おきのlagを5回計算して吐き出す...(1)
EXP <- Embed.dif(EXP, V1, V2)
DATA <- data.frame("OBJ"=head(OBJ,nrow(EXP)), EXP)

# ---------------------------------------------
# 学習ステップ
# ランダムフォレスト（RandomForestパッケージ）
# ---------------------------------------------

set.seed(0)

model <- train(
  OBJ ~ (.)^2, 
  data = DATA, 
  method = "rf", 
  tuneLength = 4,
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv")
)
saveRDS(model, paste("./",V1,"_",V2,"_",V0,"days_predict",".model",sep=""))
# 3日おきのlagを5回計算して吐き出す...(1)
    EXP_test <- Embed.dif(OBJ, V1, V2)
    colnames(EXP_test) <- head(model$coefnames, ncol(EXP_test))   # 予測に使用した説明変数のcolnamesに合わせている(エラー回避)

# 予測
    PRED <- predict(model, EXP_test)

# 評価
# 平均平方自乗誤差(RMSE)で評価
    RMSE <- rmse( d.high.test, head(PRED, V0) )
    write.csv(RMSE, paste("./",V1,"_",V2,"_",V0,"days_predict_RMSE",".csv",sep=""),quote=F, row.names=F)

# 図面作成
png(paste("./",V1,"_",V2,"_",V0,"days_predict",".png",sep=""))
plot(rev(PRED), ylim=c(3000, 7000))
par(new=T)
plot(rev(head(x$high, length(PRED))), col="red", ylim=c(3000,7000))
dev.off()

}

makeModel4HighStockprices(10, 5, 7, 6902)

# 参考までに、明日からどうなるか予測
model <- readRDS("./5_7_10days_predict.model")
x <- getStockprices(6902)
d.high <- x$high
EXP_test <- Embed.dif(d.high, 5, 7)
colnames(EXP_test) <- head(model$coefnames, ncol(EXP_test))   # 予測に使用した説明変数のcolnamesに合わせている(エラー回避)
PRED <- predict(model, EXP_test)

# 図面作成
png(paste("./",5,"_",7,"_",10,"days_predict_further",".png",sep=""))
plot(x=c(1:length(PRED)), y=rev(PRED), ylim=c(3000, 7000), xlim=c(1, length(PRED)))
par(new=T)
plot(x=c(1:length(PRED)-10), y=rev(head(x$high, length(PRED))), col="red", ylim=c(3000,7000), xlim=c(1, length(PRED)))
dev.off()
