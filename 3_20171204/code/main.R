# --- ライブラリ読み込み
library("XML")
library(gpclib) # maptools の前提パッケージ gpclib を R で使うのに必要
library(maptools)
library(RColorBrewer) # 統計グラフで使える便利なカラーパレット
require(extrafont)
require(Cairo)

# --- 関数群の読み込み(画像ファイル作成用)
source("./src/VisMap.R")


# --- フォントの読み込み
loadfonts(quiet=TRUE)
CairoFonts(regular = "Rounded M+ 2c light",bold="Rounded M+ 2c bold")

# --- te4(まとめた後のファイル)が存在するかで条件分岐。
# --- もし存在しなかった場合のみ、te4を作成。
if (file.exists("./files/te4.obj")){
    te4 <- readRDS("./files/te4.obj")
} else {

# --- 関数群の読み込み
    source("./src/GetGeocode.R")
    source("./src/integrate.R") # hoikusho.Nagoya(名古屋市の保育所リスト)を作成


# --- |保育所名称|住所| 
    b <- data.frame(hoikusho.Nagoya[,1],hoikusho.Nagoya[,3])

# --- te1(一時変数)の初期化
    te1 <- ""

# --- |緯度|経度|保育所名称|住所|色|...に変更 
    for (i in 1:nrow(b) ){
        te1 <- getGeocode(paste(b[i,2]),Geo)
        te2 <- cbind(te1, b[i,2])
        if (i==1){
            te3 <- te2
        } else {
            te3 <- rbind(te3,te2)
        }
    }

# --- 書き起こすための最終データ
    te4 <- data.frame(lat=te3[,1],
        lon=te3[,2],
        name=b[,1],
        jusho=b[,2]
    )
    saveRDS(te4,"./files/te4.obj")

}

# --- 図面書き起こし用関数
# --- $1: 図面の名前 "sample.pdfなど"
# --- $2: shpファイル
# --- $3: 街区レベルの表示したい地域名(名古屋市-->Nagoya)
# --- $4: |緯度|経度|ラベル|色名|のdataframe
visMap("imagename", jpn, "Nagoya", te4)