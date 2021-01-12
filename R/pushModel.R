#'
#' @title Push model to DataSHIELD server
#' @description This function pushes a serialized model and assigns a server
#'   variable to it.
#' @param connections [DSI::connection] Connection to an OPAL server.
#' @param mod [arbitrary] R object containing a model which is used for predictions on the server side.
#' @param sep [character(1L)] Separator used to collapse the binary elements.
#' @param check_serialization [logical(1L)] Check if the serialized model can be deserialized
#' @param package [character(1L)] Package required for model predictions.
#' @param install_if_not_available [logical(1L)] Install package if it is not installed.
#' @author Daniel S.
#' @export
pushModel = function (connections, mod, sep = "-", check_serialization = TRUE, package = NULL, install_if_not_available = TRUE)
{
  mod_name = deparse(substitute(mod))
  bin = encodeModel(mod, mod_name, sep, check_serialization)
  if (is.null(package)) { package = "NULL" } else { packge = paste0("\"", package, "\"")}

  call = paste0("decodeModel(\"", bin, "\", \"", sep = attr(bin, "sep"), "\", ", package, ",", install_if_not_available, ")")
  cq = NULL # Dummy for checks
  eval(parse(text = paste0("cq = quote(", call, ")")))
  DSI::datashield.assign(connections, names(bin), cq)
}

