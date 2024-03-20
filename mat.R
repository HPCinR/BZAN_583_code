x = matrix(runif(1e7), nrow = 1e4)
system.time(crossprod(x))
system.time(t(x) %*% x)