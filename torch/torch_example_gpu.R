## This code runs the example from 
## https://blogs.rstudio.com/ai/posts/2020-09-29-introducing-torch-for-r/

library(torch)
library(torchvision)

train_ds <- kmnist_dataset(
  ".",
  download = TRUE,
  train = TRUE,
  transform = transform_to_tensor
)

test_ds <- kmnist_dataset(
  ".",
  download = TRUE,
  train = FALSE,
  transform = transform_to_tensor
)

train_ds[1]

train_ds[1][[1]]$size()

train_dl <- dataloader(train_ds, batch_size = 32, shuffle = TRUE)
test_dl <- dataloader(test_ds, batch_size = 32)

train_iter <- train_dl$.iter()
train_iter$.next()

## display a set of characters from the data
par(mfrow = c(4,8), mar = rep(0, 4))
images <- train_dl$.iter()$.next()[[1]][1:32, 1, , ] 
images %>%
  purrr::array_tree(1) %>%
  purrr::map(as.raster) %>%
  purrr::iwalk(~{plot(.x)})


net <- nn_module(
  
  "KMNIST-CNN",
  
  initialize = function() {
    # in_channels, out_channels, kernel_size, stride = 1, padding = 0
    self$conv1 <- nn_conv2d(1, 32, 3)
    self$conv2 <- nn_conv2d(32, 64, 3)
    self$dropout1 <- nn_dropout2d(0.25)
    self$dropout2 <- nn_dropout2d(0.5)
    self$fc1 <- nn_linear(9216, 128)
    self$fc2 <- nn_linear(128, 10)
  },
  
  forward = function(x) {
    x %>% 
      self$conv1() %>%
      nnf_relu() %>%
      self$conv2() %>%
      nnf_relu() %>%
      nnf_max_pool2d(2) %>%
      self$dropout1() %>%
      torch_flatten(start_dim = 2) %>%
      self$fc1() %>%
      nnf_relu() %>%
      self$dropout2() %>%
      self$fc2()
  }
)

x <- torch_randn(c(1, 1, 28, 28))

conv1 <- nn_conv2d(1, 32, 3)
conv1(x)$size()

conv2 <- nn_conv2d(32, 64, 3)
(conv1(x) %>% conv2())$size()

## instantiate the model on the GPU
model <- net()
model$to(device = "cuda")

optimizer <- optim_adam(model$parameters)

## The training loop
for (epoch in 1:5) {
  
  l <- c()
  
  coro::loop(for (b in train_dl) {
    # make sure each batch's gradient updates are calculated from a fresh start
    optimizer$zero_grad()
    # get model predictions
    output <- model(b[[1]]$to(device = "cuda"))
    # calculate loss
    loss <- nnf_cross_entropy(output, b[[2]]$to(device = "cuda"))
    # calculate gradient
    loss$backward()
    # apply weight updates
    optimizer$step()
    # track losses
    l <- c(l, loss$item())
  })
  
  cat(sprintf("Loss at epoch %d: %3f\n", epoch, mean(l)))
}

## Put the model in eval mode
model$eval()

## Iterate over the test set
test_losses <- c()
total <- 0
correct <- 0

coro::loop(for (b in test_dl) {
  output <- model(b[[1]]$to(device = "cuda"))
  labels <- b[[2]]$to(device = "cuda")
  loss <- nnf_cross_entropy(output, labels)
  test_losses <- c(test_losses, loss$item())
  # torch_max returns a list, with position 1 containing the values 
  # and position 2 containing the respective indices
  predicted <- torch_max(output$data(), dim = 2)[[2]]
  total <- total + labels$size(1)
  # add number of correct classifications in this batch to the aggregate
  correct <- correct + (predicted == labels)$sum()$item()
})

mean(test_losses)

test_accuracy <-  correct/total
test_accuracy
