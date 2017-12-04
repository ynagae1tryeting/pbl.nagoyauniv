library("XML")



trim <- function (data){
    c <-"愛知県名古屋市"
    name <- data[,3] 
#    b <- sub("-.*","",paste(c,name,sep="")) #-番地以降を削除
     b <- paste(c,name,sep="")
    x <- data.frame("認可施設・事業所等名"=data[,1],
                    "利用定員"=data[,2],
                    "所在地"=b,
                    "電話番号"=data[,4],
                    "公私"=data[,5],
                    "設置主体"=data[,6],
                    "施設の類型"=data[,7],
                    "開設時間(平日)"=data[,8],
                    "受入可能年齢"=data[,9],
                    "特別保育の実施状況"=data[,10]
                    )
    x <- x[-1,]
    return(x)
}

# --- objファイルの有無で条件分岐
if (!file.exists("./files/hoikusho.Nagoya.obj2")) {

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003259.html")
y <- data.frame(x$`千種区の認可施設・事業所一覧`)
chikusa <- trim(y)

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003297.html")
y <- data.frame(x$`東区内の認可施設・事業所一覧`)
higashi <- trim(y)

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003290.html")
y <- data.frame(x$`北区内の認可施設・事業所一覧`)
kita <- trim(y)

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003265.html")
y <- data.frame(x$`西区内の認可施設・事業所一覧`)
nishi <- trim(y)

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003270.html")
y <- data.frame(x$`中村区内の認可施設・事業所一覧`)
nakamura <- trim(y)
 

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003301.html")
y <- data.frame(x$`中区内の認可施設・事業所一覧`)
naka <- trim(y)
 
x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003343.html")
y <- data.frame(x$`昭和区内の認可施設・事業所一覧`)
showa <- trim(y)

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003354.html")
y <- data.frame(x$`瑞穂区内の認可施設・事業所一覧`)
mizuho <- trim(y)
 
x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003309.html")
y <- data.frame(x$`熱田区内の認可施設・事業所一覧`)
atsuta <- trim(y)
 
x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003278.html")
y <- data.frame(x$`中川区内の認可施設・事業所一覧`)
nakagawa <- trim(y)

 
x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003283.html")
y <- data.frame(x$`港区内の認可施設・事業所一覧`)
minato <- trim(y)

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003338.html")
y <- data.frame(x$`南区内の認可施設・事業所一覧`)
minami <- trim(y)

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003369.html")
y <- data.frame(x$`守山区内の認可施設・事業所一覧`)
moriyama <- trim(y)

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003395.html")
y <- data.frame(x$`緑区内の認可施設・事業所一覧`)
midori <- trim(y)

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003382.html")
y <- data.frame(x$`名東区内の認可施設・事業所一覧`)
meito <- trim(y)

x <- readHTMLTable("http://www.city.nagoya.jp/kodomoseishonen/page/0000003388.html")
y <- data.frame(x$`天白区内の認可施設・事業所一覧`)
tenpaku <- trim(y)

hoikusho.Nagoya2 <- rbind(chikusa,higashi,kita,nishi,nakamura,naka,showa,mizuho,atsuta,nakagawa,minato,minami,moriyama,midori,meito,tenpaku)


    saveRDS(hoikusho.Nagoya2,"./files/hoikusho.Nagoya2.obj")
} else {
    hoikusho.Nagoya2 <- readRDS("./files/hoikusho.Nagoya2.obj")
}
