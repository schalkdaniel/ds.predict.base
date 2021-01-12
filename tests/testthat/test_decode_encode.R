context("Ceck if decoding and encoding produces the same model")

test_that("encode produces outpout", {
  mod = lm(Sepal.Width ~ ., data = iris)

  expect_error(encodeModel(mod, sep = 2))
  expect_error(encodeModel(mod, sep = c("-", "xxx")))

  expect_silent({ bin = encodeModel(mod) })
  expect_equal(attr(bin, "sep"), "-")
  expect_equal(names(bin), "mod")
  expect_true(is.character(bin))

  expect_silent({ bin = encodeModel(mod, sep = "xxx") })
  expect_equal(attr(bin, "sep"), "xxx")
  expect_true(is.character(bin))
})

test_that("Decode - encode works properly", {
  mod = lm(Sepal.Width ~ ., data = iris)

  expect_silent({ bin = encodeModel(mod) })
  expect_silent({ mod_b = decodeModel(bin)})
  expect_equal(mod, mod_b)

  expect_silent({ bin = encodeModel(mod, sep = "xxx") })
  expect_error({ mod_b = decodeModel(bin)})
  expect_silent({ mod_b = decodeModel(bin, sep = "xxx")})
  expect_equal(mod, mod_b)
})

