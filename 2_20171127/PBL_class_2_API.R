# -------------------------------------------------------
# 講義用(2-2)
# Tryeting APIを用いて、filepathで指定したcsvファイルをアップロード、データ取得をする。
# -------------------------------------------------------


getDataTryetingApi <- function(filepath, api){
    #  tryetingのwebapiから入力を受け取るためのコード
    data <- 
        data.frame(
            system(paste("cat ",filepath,"| curl --data-binary @- https://ai.tryeting.jp/Api/Analyze/",api, sep=""),
                    intern = T
            )
        )
}

d <- getDataTryetingApi("./ファイルの場所(パス)", api)
