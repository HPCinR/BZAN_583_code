m = 1e3
n = 1e5
mat = matrix(runif(m*n), nrow = m)
system.time({
  result1 = NULL
  for(i in seq_len(n)) {
    newres = mean(mat[, i])
    result1 = c(result1, newres)
  }})

system.time({
  result2 = vector("double", n)
  for(i in seq_len(n)) {
    result2[i] = mean(mat[, i])
  }})

all.equal(result1, result2)
