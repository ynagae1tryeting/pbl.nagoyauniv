# --- 街区レベルの住所を緯度経度に直すための参考データ(愛知県)
#Geo <- read.csv("./data/23_2015_utf8.csv")
Geo <- readRDS("./data/Geo.obj")

# --- 住所から(ざっくりとした)緯度・経度を吐き出してくれる関数
# --- 引数1=住所 引数2=参考データ(Geo)
getGeocode <- function (jusho, Geo) {
    if (!is.character(jusho)){
        print("引数を文字列として入力してください。")
        break
    } else {
        y<- paste(Geo[,1],Geo[,2],Geo[,3],Geo[,4],sep="")
        target<- jusho
        xnum<-pmatch(target,y)
        z<-Geo[xnum,8:9]
    }
    return(z)
}
