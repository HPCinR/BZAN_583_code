x = matrix(runif(1e5*500), ncol = 500)


Rprof()
x_pr = prcomp(x, retx = FALSE)
Rprof(NULL)
summaryRprof()
