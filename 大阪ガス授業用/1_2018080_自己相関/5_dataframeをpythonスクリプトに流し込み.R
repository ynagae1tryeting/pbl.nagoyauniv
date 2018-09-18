# --------------------------
# (c) yuki nagae @ tryeting
# MIT
# --------------------------
# 次の2時間後の価格を予測してみよう


# データ取得... 日本語ファイルのため、いきなり読めない。
tmpfile <-  tempfile()
system(paste("curl http://www.jepx.org/market/excel/spot_2018.csv > ", tmpfile, sep=""))
system(paste("nkf -w --overwrite ", tmpfile, sep=""))  # nkfによる文字エンコーディングの変換
d <- read.csv(tmpfile)  # UTF8によるデータ読み込み


# //////////////////////
# 説明変数の作成
# 方針(1)〜2時間前のデータを使用して(エリアプライス関西)を予測してみよう！
# 30分ごとにデータが蓄積
# 2時間... 4行分ずらせばいい
OBJ <- d[,12]
N <- 3
y <- embed(OBJ, N)[,1]
X <- embed(OBJ, N)[,ncol(embed(OBJ, N))]
D <- data.frame("y"=y, "X"=X)

# 入力データを吐き出すための一時ファイル作り
inputf <- tempfile()

# 一時ファイルにcsv吐き出し
write.csv(D, inputf, quote=F, row.names=F)

# system関数でデータをpythonに流し込み...出力を一時ファイルへ
system(paste(

    "python ./4_standalone.py ", inputf
    
    ,sep=""))

# 結果を受け取り、Rからカレントディレクトリにcsvとして焼き直し
R2 <- read.csv("./R2SCORE.csv")
message(paste("R2SCORE : ", R2, sep=""))

# Rscript --vanilla --slave 