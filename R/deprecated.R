# Deprecated functions and arguments
#
# Author: mjskay
###############################################################################



# ggdist-deprecated ----------------------------------------------------

#' Deprecated functions and arguments in ggdist
#'
#' Deprecated functions and arguments and their alternatives are listed below.
#'
#' @section Deprecated stats and geoms:
#'
#' The `stat_sample_...` and `stat_dist_...` families of stats were merged in ggdist 3.1.
#' This means:
#'
#' - `stat_dist_...` is deprecated. For any code using `stat_dist_XXX()`, you should now
#' be able to use `stat_XXX()` instead without additional modifications in almost all cases.
#' - `stat_sample_slabinterval()` is deprecated. You should be able to use
#' [stat_slabinterval()] instead without additional modifications in almost all cases.
#'
#' The old `stat_dist_...` names are currently kept as aliases, but may be removed in the future.
#'
#' @section Deprecated arguments:
#'
#' Deprecated parameters for [stat_slabinterval()] and family:
#'
#' - The `.prob` argument, which is a long-deprecated alias for `.width`, was
#' removed in ggdist 3.1.
#' - The `limits_function` argument: this was a parameter for determining the
#' function to compute limits of the slab in [stat_slabinterval()] and its
#' derived stats. This function is really an internal function only needed by
#' subclasses of the base class, yet added a lot of noise to the documentation,
#' so it was replaced with `AbstractStatSlabInterval$compute_limits()`.
#' - The `limits_args` argument: extra stat parameters are now passed through to
#' the `...` arguments to `AbstractStatSlabInterval$compute_limits()`; use
#' these instead.
#' - The `slab_function` argument: this was a parameter for determining the
#' function to compute slabs in [stat_slabinterval()] and its
#' derived stats. This function is really an internal function only needed by
#' subclasses of the base class, yet added a lot of noise to the documentation,
#' so it was replaced with `AbstractStatSlabInterval$compute_slab()`.
#' - The `slab_args` argument: extra stat parameters are now passed through to
#' the `...` arguments to `AbstractStatSlabInterval$compute_slab()`; use
#' these instead.
#' - The `slab_type` argument: instead of setting the slab type, either adjust
#' the `density` argument (e.g. use `density = "histogram"` to replace
#' `slab_type = "histogram"`) or use the `pdf` or `cdf` computed variables
#' mapped onto an appropriate aesthetic (e.g. use `aes(thickness = after_stat(cdf))`
#' to create a CDF).
#' - The `interval_function` and `fun.data` arguments: these were parameters for determining the
#' function to compute intervals in [stat_slabinterval()] and its
#' derived stats. This function is really an internal function only needed by
#' subclasses of the base class, yet added a lot of noise to the documentation,
#' so it was replaced with `AbstractStatSlabInterval$compute_interval()`.
#' - The `interval_args` and `fun.args` arguments: to pass extra arguments to
#' a `point_interval` replace the value of the `point_interval` argument with
#' a simple wrapper; e.g. `stat_halfeye(point_interval = \(...) point_interval(..., extra_arg = XXX))`
#'
#' Deprecated parameters for [geom_slabinterval()] and family:
#'
#' - The `size_domain` and `size_range` arguments, which are long-deprecated aliases
#' for `interval_size_domain` and `interval_size_range`, were removed in ggdist 3.1.
#'
#' @format NULL
#' @usage NULL
#' @author Matthew Kay
#' @name ggdist-deprecated
NULL


# stat_sample_... ---------------------------------------------------------

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
StatSampleSlabinterval = StatSlabinterval

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_sample_slabinterval = stat_slabinterval


# stat_dist_... -----------------------------------------------------------

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
StatDistSlabinterval = StatSlabinterval

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_slabinterval = stat_slabinterval

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_halfeye = stat_halfeye

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_eye = stat_eye

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_ccdfinterval = stat_ccdfinterval

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_cdfinterval = stat_cdfinterval

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_gradientinterval = stat_gradientinterval

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_slab = stat_slab

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_pointinterval = stat_pointinterval

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_interval = stat_interval

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_lineribbon = stat_lineribbon

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_dotsinterval = stat_dotsinterval

#' @rdname ggdist-deprecated
#' @format NULL
#' @usage NULL
#' @export
stat_dist_dots = stat_dots
