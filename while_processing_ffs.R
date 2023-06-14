
rf <- ranger(Species ~ ., data = iris)
treeInfo(rf, 1)

treeInfo(model, tree = 1)
