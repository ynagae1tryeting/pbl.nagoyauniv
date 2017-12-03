##### 名古屋市の保育園可視化プログラム
　名古屋市の公開している認可型保育園のリストをスクレイピングして、名古屋市の白地図上に位置を可視化する。作業ディレクトリに、図面データは吐き出される。

##### 実行環境
- MacOSおよびそのほかのlinuxOS
- R実行環境(ネットにいろいろ落ちてるから、探してみるべし)
- install.packages
`XML`
`gpclib` (maptools の前提パッケージ gpclib を R で使うのに必要)
`maptools`
`RColorBrewer` (統計グラフで使える便利なカラーパレット)
`extrafont`
`Cairo`

##### 使用方法
　下記の手順で実行すればよい。

1. main.Rが置いてあるdirectryに移動。
2. `Rscript --vanilla --slave ./main.R`
3. 同じdirectryに`imagename.pdf`が生成。

##### 最後に
　./files/te4.objが、可視化用のデーファイル。もしここからcsv出したいときは、
1. R起動
2. `data <- readRDS("./files/te4.obj")`
3. `write.csv(data, "./files/te4.csv", row.names=F, quote=F)`
でOK。ただし、非常にデータが大きい(>100MB)ので、気をつけること(それが理由でobjにしてある)。
