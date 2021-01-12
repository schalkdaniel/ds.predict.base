context("Check if predict works locally")

test_that("Predict works locally", {
  dat   = cbind(age = sample(20:100, 100L, TRUE), height = runif(100L, 150, 220))
  probs = 1 / (1 + exp(-as.numeric(dat %*% c(-3, 1))))

  # Write to global env. to pass checks which require on object defined there:
  gender = rbinom(100L, 1L, probs)
  dat <<- data.frame(gender = gender, dat)
  dat = data.frame(gender = gender, dat)
  expect_warning({ mod <<- glm(gender ~ age + height, family = "binomial", data = dat) })

  expect_error(predictModel(connections, false_mod, "pred", dat_name = "dat"))
  expect_error(predictModel(connections, mod, "pred", dat_name = "false_data"))
  expect_error(predictModel(connections, false_mod, c("pred1", "pred2"), dat_name = "dat"))
  expect_error(predictModel(connections, mod, "pred", dat_name = c("dat1", "dat2")))

  expect_silent({ cl = predictModel(connections, mod, "pred", dat_name = "dat", just_return_call = TRUE) })
  pred = eval(cl)
  pred1 = predict(mod, newdata = dat)

  expect_equal(pred, pred1)

  expect_silent({ cl = predictModel(connections, mod, "pred", "dat", predict_fun = "predict(mod, newdata = D, type = 'response')", just_return_call = TRUE) })
  pred = eval(cl)
  pred1 = predict(mod, newdata = dat, type = "response")

  expect_equal(pred, pred1)
})
