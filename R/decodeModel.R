#'
#' @title Deserialize model
#' @description Decode given string of serialized model. The deserialized model is then
#'   assigned to a new variable
#' @param bin [character(1L)] Binary string value containing the serialized model.
#' @param sep [character(1L)] Separator used to collapse the binary elements.
#' @param package [character(1L)] Package required for model predictions.
#' @param install_if_not_available [logical(1L)] Install package if it is not installed.
#' @return Model object
#' @author Daniel S.
#' @examples
#' mod = lm(Sepal.Width ~ ., data = iris)
#' bin = encodeModel(mod)
#' mod_b = decodeModel(bin)
#' all.equal(mod, mod_b)
#' @export
decodeModel = function (bin, sep = "-", package = NULL, install_if_not_available = TRUE)
{
  checkmate::assertCharacter(bin, len = 1L, null.ok = FALSE, any.missing = FALSE)
  checkmate::assertCharacter(sep, len = 1L, null.ok = FALSE, any.missing = FALSE)
  checkmate::assertCharacter(package, len = 1L, null.ok = TRUE, any.missing = FALSE)
  checkmate::assertLogical(install_if_not_available, len = 1L, null.ok = FALSE, any.missing = FALSE)

  if (! grepl(sep, bin)) stop("Separator does not appear in binary string.")

  # Check if model is installed and install if not:
  if (! is.null(package) && require(package, quietly = TRUE, character.only = TRUE)) {
    if (install_if_not_available) utils::install.packages(package)
  }
  #if (! package %in% rownames(installed.packages())) install.packages(package)

  mod_binary_str_deparse = strsplit(bin, split = sep)[[1]]
  mod_raw = as.raw(as.hexmode(mod_binary_str_deparse))
  mod = unserialize(mod_raw)

  return(mod)
}

