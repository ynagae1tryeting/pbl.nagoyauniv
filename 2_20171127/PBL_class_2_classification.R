# -------------------------------------------------------
# 講義用(2-1)
# Fisherのアヤメの種類分け(classification)を行う
# -------------------------------------------------------

library(caret)

# -----------------------------------------------
# 1. データセットの読み込み
# -----------------------------------------------
indexIris <- which(1:nrow(iris)%%3 == 0)
indexIris
#[1]   3   6   9  12  15  18  21  24  27  30  33  36  39  42  45  48  51  54  57  60  63  66  69  72  75  78  81  84  87  90
#[31]  93  96  99 102 105 108 111 114 117 120 123 126 129 132 135 138 141 144 147 150
irisTrain <- iris[-indexIris,]
irisTest <- iris[indexIris,]

# -------------------------------------------------------
# 2. caretによるモデル化
# -------------------------------------------------------

# 続いて、モデル化とハイパーパラメタのチューニングをします。
# ニューラルネットワークとランダムフォレスト（RandomForestパッケージ）のみを使います。
# ニューラルネットワークの場合は、linout = Fとすることに注意してください。分類の場合はFALSEを指定します。

# ニューラルネット(nnet)
set.seed(0)
irisNnet <- train(
  Species ~ (.)^2, 
  data = irisTrain, 
  method = "nnet", 
  tuneLength = 4,
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv"),
  linout = F
)
 
# ランダムフォレスト（RandomForestパッケージ）
set.seed(0)
irisRF <- train(
  Species ~ (.)^2, 
  data = irisTrain, 
  method = "rf", 
  tuneLength = 4,
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv")
)

# -------------------------------------------------------
# 3. predict()による予測
# -------------------------------------------------------

# ニューラルネットワーク
predIrisNnet <- predict(irisNnet, irisTest)
# ランダムフォレスト（RandomForestパッケージ）
predIrisRF <- predict(irisRF, irisTest)

# -------------------------------------------------------
# 4. 精度評価
# -------------------------------------------------------

# 続いて、精度評価です。
# 分類問題の場合は、confusionMatrix()という関数を使うと簡単です。

# 評価
# ニューラルネットワーク
confusionMatrix(data = predIrisNnet, irisTest$Species)

# ........................................................
# 実行結果
# $positive
# NULL
# $table
#            Reference
# Prediction   setosa versicolor virginica
#   setosa         16          0         0
#   versicolor      0         14         0
#   virginica       0          3        17

# $overall
#       Accuracy          Kappa  AccuracyLower  AccuracyUpper   AccuracyNull AccuracyPValue  McnemarPValue 
#   9.400000e-01   9.099640e-01   8.345181e-01   9.874514e-01   3.400000e-01   5.551972e-19            NaN 

# $byClass
#                   Sensitivity Specificity Pos Pred Value Neg Pred Value Precision    Recall        F1 Prevalence Detection Rate Detection Prevalence Balanced Accuracy
# Class: setosa       1.0000000   1.0000000           1.00      1.0000000      1.00 1.0000000 1.0000000       0.32           0.32                 0.32         1.0000000
# Class: versicolor   0.8235294   1.0000000           1.00      0.9166667      1.00 0.8235294 0.9032258       0.34           0.28                 0.28         0.9117647
# Class: virginica    1.0000000   0.9090909           0.85      1.0000000      0.85 1.0000000 0.9189189       0.34           0.34                 0.40         0.9545455

# $mode
# [1] "sens_spec"

# $dots
# list()

# attr(,"class")
# [1] "confusionMatrix"
# ........................................................

# ランダムフォレスト（RandomForestパッケージ）
confusionMatrix(data = predIrisRF, irisTest$Species)

# ........................................................
# 実行結果
# $positive
# NULL

# $table
#             Reference
# Prediction   setosa versicolor virginica
#   setosa         16          0         0
#   versicolor      0         14         1
#   virginica       0          3        16

# $overall
#       Accuracy          Kappa  AccuracyLower  AccuracyUpper   AccuracyNull AccuracyPValue  McnemarPValue 
#   9.200000e-01   8.799520e-01   8.076572e-01   9.777720e-01   3.400000e-01   1.281546e-17            NaN 

# $byClass
#                   Sensitivity Specificity Pos Pred Value Neg Pred Value Precision    Recall        F1 Prevalence Detection Rate Detection Prevalence Balanced Accuracy
# Class: setosa       1.0000000   1.0000000      1.0000000      1.0000000 1.0000000 1.0000000 1.0000000       0.32           0.32                 0.32         1.0000000
# Class: versicolor   0.8235294   0.9696970      0.9333333      0.9142857 0.9333333 0.8235294 0.8750000       0.34           0.28                 0.30         0.8966132
# Class: virginica    0.9411765   0.9090909      0.8421053      0.9677419 0.8421053 0.9411765 0.8888889       0.34           0.32                 0.38         0.9251337

# $mode
# [1] "sens_spec"

# $dots
# list()

# attr(,"class")
# [1] "confusionMatrix"
# ........................................................

# モデルの保存
saveRDS(irisNnet,"./irisNnet.model")
saveRDS(irisRF,"./irisRF.model")
