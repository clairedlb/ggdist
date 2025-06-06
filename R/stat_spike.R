# spike stat
#
# Author: mjskay
###############################################################################


#' Spike plot (ggplot2 stat)
#'
#' Stat for drawing "spikes" (optionally with points on them) at specific points
#' on a distribution (numerical or determined as a function of the distribution),
#' intended for annotating [stat_slabinterval()] geometries.
#'
#' @details
#' This stat computes slab values (i.e. PDF and CDF values) at specified locations
#' on a distribution, as determined by the `at` parameter.
#' @param at <[numeric] | [function] | [character] | [list]> The points at which to
#' evaluate the PDF and CDF of the distribution. One of:
#'   - [numeric] vector: points to evaluate the PDF and CDF of the distributions at.
#'   - function or character vector: function (or names of functions) which,
#'     when applied on a distribution-like object (e.g. a \pkg{distributional} object or a
#'     [posterior::rvar()]), returns a vector of values to evaluate the distribution functions at.
#'   - a [list] where each element is any of the above (e.g. a [numeric], function, or
#'     name of a function): the evaluation points determined by each element of the
#'     list are concatenated together. This means, e.g., `c(0, median, qi)` would add
#'     a spike at `0`, the median, and the endpoints of the `qi` of the distribution.
#'
#' The values of `at` are also converted into a character vector which is supplied
#' as a computed variable (also called `at`) generated by this `stat`, which can be
#' mapped onto aesthetics using [`after_stat()`][ggplot2::after_stat]. Non-empty names
#' can be used to override the values of the computed variable; e.g.
#' `at = c(zero = 0, "median", mode = "Mode")` will generate a computed variable with
#' the values `c("zero", "median", "mode")` that is evaluated at `0`, the median, and
#' the mode of the distribution.
#' @inheritParams stat_slab
#' @inheritParams geom_spike
#' @eval rd_layer_params("spike", StatSpike, as_dots = TRUE)
#' @param geom <[Geom][ggplot2::Geom] | [string][character]> Use to override the default
#' connection between [stat_spike()] and [geom_spike()]
#' @template details-x-y-xdist-ydist
#' @return A [ggplot2::Stat] representing a spike geometry which can be added to a [`ggplot()`][ggplot2::ggplot] object.
#' @eval rd_spike_aesthetics("spike", StatSpike)
#' @eval rd_slabinterval_computed_variables(StatSpike)
#' @seealso See [geom_spike()] for the geom underlying this stat.
#'   See [stat_slabinterval()] for the stat this shortcut is based on.
#' @family slabinterval stats
#' @examples
#' library(ggplot2)
#' library(distributional)
#' library(dplyr)
#'
#' df = tibble(
#'   d = c(dist_normal(1), dist_gamma(2,2)), g = c("a", "b")
#' )
#'
#' # annotate the density at the mode of a distribution
#' df %>%
#'   ggplot(aes(y = g, xdist = d)) +
#'   stat_slab(aes(xdist = d)) +
#'   stat_spike(at = "Mode") +
#'   # need shared thickness scale so that stat_slab and geom_spike line up
#'   scale_thickness_shared()
#'
#' # annotate the endpoints of intervals of a distribution
#' # here we'll use an arrow instead of a point by setting size = 0
#' arrow_spec = arrow(angle = 45, type = "closed", length = unit(4, "pt"))
#' df %>%
#'   ggplot(aes(y = g, xdist = d)) +
#'   stat_halfeye(point_interval = mode_hdci) +
#'   stat_spike(
#'     at = function(x) hdci(x, .width = .66),
#'     size = 0, arrow = arrow_spec, color = "blue", linewidth = 0.75
#'   ) +
#'   scale_thickness_shared()
#'
#' # annotate quantiles of a sample
#' set.seed(1234)
#' data.frame(x = rnorm(1000, 1:2), g = c("a","b")) %>%
#'   ggplot(aes(x, g)) +
#'   stat_slab() +
#'   stat_spike(at = function(x) quantile(x, ppoints(10))) +
#'   scale_thickness_shared()
#'
#' @name stat_spike
NULL


# compute_slab ------------------------------------------------------------

#' StatSpike$compute_slab()
#' @noRd
compute_slab_spike = function(
  self, data, scales, trans, input, orientation,
  slab_type, at,
  ...
) {
  define_orientation_variables(orientation)

  # calculate slab functions
  s_data = ggproto_parent(StatSlab, self)$compute_slab(
    data, scales = scales, trans = trans, input = input, orientation = orientation,
    slab_type = slab_type,
    ...
  )

  dist = data$dist
  pdf_fun = approx_pdf(dist, s_data$.input, s_data$pdf)
  cdf_fun = approx_cdf(dist, s_data$.input, s_data$cdf)

  # determine evaluation points (inputs to slab functions)
  input_nested = lapply(at, function(at_i) {
    input_i = if (is.function(at_i)) at_i(dist) else at_i
    # unlist here so that the call to lengths() on input_nested
    # below will return the correct lengths of each element of input_nested
    unlist(input_i, use.names = FALSE)
  })
  # needs to be a vector (e.g. in cases of interval functions
  # like qi() which return matrices)
  input = unlist(input_nested, use.names = FALSE, recursive = FALSE)
  input_names = rep(names(at), times = lengths(input_nested))

  # evaluate functions
  pdf = pdf_fun(input)
  cdf = cdf_fun(input)

  data_frame0(
    .input = input,
    at = input_names,
    f = if (length(input) > 0) get_slab_function(slab_type, list(pdf = pdf, cdf = cdf)),
    pdf = pdf,
    cdf = cdf,
    n = if (length(input) > 0) s_data$n[[1]]
  )
}


# stat_spike --------------------------------------------------------------

#' @rdname ggdist-ggproto
#' @format NULL
#' @usage NULL
#' @import ggplot2
#' @export
StatSpike = ggproto("StatSpike", StatSlab,
  default_params = defaults(list(
    at = "median"
  ), StatSlab$default_params),

  setup_params = function(self, data, params) {
    params = ggproto_parent(StatSlab, self)$setup_params(data, params)

    # normalize the `at` parameter so it is always a named list of functions,
    # and scalar numerics
    params$at = check_at(params$at)

    params
  },

  # workaround (#84)
  compute_slab = function(self, ...) compute_slab_spike(self, ...)
)
#' @rdname stat_spike
#' @export
stat_spike = make_stat(StatSpike, geom = "spike")


# helpers -----------------------------------------------------------------

#' check the `at` parameter and normalize it to a flat list of named scalars
#' that are either functions or numerics, generating sensible names for each
#' list element.
#' @param at `at` as accepted by `stat_spike()`; i.e. a character vector
#'  of function names, a numeric vector of evaluation points, a function, or
#'  a list of any combination of those.
#' @returns a named list, where each element is either a single function
#'  (corresponding to functions or function names in `at`) or a scalar numeric
#'  (corresponding to each evaluation point specific by numeric vectors in `at`).
#' @noRd
check_at = function(at, call = parent.frame()) {
  if (is.function(at)) at = list(at)
  if (is.numeric(at) || is.character(at) || is.null(at)) at = as.list(at)
  names(at) = rlang::names2(at)

  if (!is.list(at)) {
    cli::cli_abort(
      c(
        "{.arg at} must be a {.cls function}, {.cls numeric}, {.cls character}, or {.cls list}.",
        "x" = "{.arg at} is a {.cls {class(at)}}.",
        "i" = "See the {.arg at} parameter of {.fun ggdist::stat_spike}."
      ),
      class = "ggdist_invalid_at_param",
      call = call
    )
  }

  is_wrong_type = !map_lgl_(at, function(x) is.function(x) || is.numeric(x) || is.character(x))
  if (any(is_wrong_type)) {
    wrong_type_i = which(is_wrong_type)
    i = wrong_type_i[[1]]
    cli::cli_abort(
      c(
        "All elements of {.arg at} must be a {.cls function}, {.cls numeric}, or {.cls character}.",
        "x" = "{.arg at} is an invalid type at position {wrong_type_i}.",
        "x" = "{if (length(wrong_type_i) > 1) 'For example, '}{.code at[[{i}]]} is a {.cls {class(at[[i]])}}.",
        "i" = "See the {.arg at} parameter of {.fun ggdist::stat_spike}."
      ),
      class = "ggdist_invalid_at_param",
      call = call
    )
  }

  # push names down into vectors --- we do this so that when we unnest into a list
  # of scalars, if a name was provided for a vector it is retained
  is_not_function = !map_lgl_(at, is.function)
  named_vectors = which(rlang::have_name(at) & is_not_function)
  for (i in named_vectors) {
    if (!any(rlang::have_name(at[[i]]))) {
      names(at[[i]]) = rep(names(at)[[i]], length(at[[i]]))
      names(at)[[i]] = ""
    }
  }

  # replace character and numeric vectors with lists and unnest them --- this ensures
  # all elements of the list are scalar, which simplifies naming and logic
  at[is_not_function] = lapply(at[is_not_function], as.list)
  at = as.list(unlist(at, recursive = FALSE))

  # ensure unnamed elements have names
  fn_n = 0
  for (i in which(!rlang::have_name(at))) {
    names(at)[[i]] = if (is.function(at[[i]])) {
      fn_n = fn_n + 1
      paste0("<fn", fn_n, ">")
    } else {
      # everything is a scalar at this point, so we can assume at[[i]] has
      # length 1
      as.character(at[[i]])
    }
  }

  # find functions for strings
  is_character = map_lgl_(at, is.character)
  at[is_character] = lapply(at[is_character], match_function)

  at
}
