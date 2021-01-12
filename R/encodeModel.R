#'
#' @title Serialize model
#' @description This function serializes a given model and creates a character of length 1
#'   which can be send via DataSHIELD to a server. The string then can be deserialized on the
#'   server and used to make predictions on the server side.
#' @param mod [arbitrary] R object containing a model which is used for predictions on the server side.
#' @param mod_name [character(1L)] Name of the model.
#' @param sep [character(1L)] Separator used to collapse the binary elements.
#' @param check_serialization [logical(1L)] Check if the serialized model can be deserialized
#'   locally.
#' @return Character of length 1 containing the serialized model as string.
#' @author Daniel S.
#' @examples
#' mod = lm(Sepal.Width ~ ., data = iris)
#' bin = encodeModel(mod)
#' substr(bin, 1, 50)
#' @export
encodeModel = function (mod, mod_name = NULL, sep = "-", check_serialization = TRUE)
{
  checkmate::assertCharacter(sep, len = 1L, null.ok = FALSE, any.missing = FALSE)
  checkmate::assertCharacter(mod_name, len = 1L, null.ok = TRUE, any.missing = FALSE)

  if (is.null(mod_name)) mod_name = deparse(substitute(mod))
  # serialize model
  mod_binary = serialize(mod, connection = NULL)
  mod_binary_str = as.character(mod_binary)
  mod_binary_str_collapsed = paste(mod_binary_str, collapse = sep)

  ## Pre check if model serialization works locally:
  if (check_serialization) {

    # get back model from serialization
    mod_binary_str_deparse = strsplit(mod_binary_str_collapsed, split = sep)[[1]]
    mod_raw = as.raw(as.hexmode(mod_binary_str_deparse))
    mod_b = unserialize(mod_raw)

    if (! all.equal(mod, mod_b)) stop("Model cannot serialized and deserialized into equal object!")
  }

  if (object.size(mod_binary_str_collapsed) > 1024^2) warning("Your object is bigger than 1 MB. Uploading larger objects may take some time.")

  names(mod_binary_str_collapsed) = mod_name
  attr(mod_binary_str_collapsed, "sep") = sep

  return(mod_binary_str_collapsed)
}


