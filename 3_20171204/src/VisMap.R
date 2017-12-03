library(gpclib) # maptools の前提パッケージ gpclib を R で使うのに必要
library(maptools)
library(RColorBrewer) # 統計グラフで使える便利なカラーパレット
require(extrafont)
require(Cairo)

#フォントの読み込み
loadfonts(quiet=TRUE)
CairoFonts(regular = "Rounded M+ 2c light",bold="Rounded M+ 2c bold")


# 経度と緯度を設定する
# 
#xlim <- c(128, 146)
#ylim <- c(30, 46)

# まずはシンプルに JPN_adm1.shp を表示してみる
#png("image.png", width = 480, height = 480, pointsize = 12, bg = "white", res = NA)
#jpn <- readShapePoly("JPN_adm1.shp")
#plot(jpn, xlim=xlim, ylim=ylim)
#dev.off()

# --- shpファイル(日本全国の緯度経度可視化データ)の読み込み
jpn <- readShapePoly("./data/JPN_adm2.shp")

# --- 図面書き起こし用関数
# --- $1: 図面の名前 "sample.pdfなど"
# --- $2: shpファイル
# --- $3: 街区レベルの表示したい地域名(名古屋市-->Nagoya)
# --- $4: |緯度|経度|ラベル|色名|のdataframe
visMap <- function(imagename, shpfile, areaname, dataframe) {
    # -- imagenameが文字列かどうか
CairoPDF(
        file = paste(imagename,'.pdf',sep=""),
        paper="a4r",
        width=11.69,
        height=8.27
    )
    par(
        mar=c(4.5,2,1,2),
        cex=0.1,
        cex.axis=0.9
    )
    # -- 行の数だけループを回して可視化
        plot(shpfile[shpfile$NAME_2==paste(areaname),])
    for (i in 1:nrow(dataframe)) {
        points(dataframe[i,2], dataframe[i,1], lwd=1, col="red")
        text(dataframe[i,2], dataframe[i,1], paste(dataframe[i,3]), col="black", adj = c(-0.3,0.5), cex=3)
        par(new=T)
    }
    dev.off()
}

