# modified colorbar guide for color/fill ramp scales
#
# Author: mjskay
###############################################################################


# guide_rampbar -------------------------------------------------------

#' Continuous guide for colour ramp scales (ggplot2 guide)
#'
#' A colour ramp bar guide that shows continuous colour ramp scales mapped onto
#' values as a smooth gradient. Designed for use with [scale_fill_ramp_continuous()]
#' and [scale_colour_ramp_continuous()]. Based on [`guide_colourbar()`][ggplot2::guide_colourbar].
#'
#' @inheritDotParams ggplot2::guide_colourbar
#' @param to <[string][character]> The color to ramp to in the guide. Corresponds to `1` on the scale.
#' @param available_aes <[character]> Vector listing the aesthetics for which a `guide_rampbar()` can be drawn.
#' @details
#' This guide creates smooth gradient color bars for use with [scale_fill_ramp_continuous()]
#' and [scale_colour_ramp_continuous()]. The color to ramp from is determined by the `from`
#' argument of the `scale_*` function, and the color to ramp to is determined by the `to` argument
#' to [guide_rampbar()].
#'
#' Guides can be specified in each `scale_*` function or in `guides()`.
#' `guide = "rampbar"` in `scale_*` is syntactic sugar for `guide = guide_rampbar()`;
#' e.g. `scale_colour_ramp_continuous(guide = "rampbar")`. For how to specify
#' the guide for each scale in more detail, see `guides()`.
#' @return
#' A guide object.
#' @author Matthew Kay
#' @family colour ramp functions
#' @examples
#'
#' library(dplyr)
#' library(ggplot2)
#' library(distributional)
#'
#' # The default guide for ramp scales is guide_legend(), which creates a
#' # discrete style scale:
#' tibble(d = dist_uniform(0, 1)) %>%
#'   ggplot(aes(y = 0, xdist = d)) +
#'   stat_slab(aes(fill_ramp = after_stat(x)), fill = "blue") +
#'   scale_fill_ramp_continuous(from = "red")
#'
#' # We can use guide_rampbar() to instead create a continuous guide, but
#' # it does not know what color to ramp to (defaults to "gray65"):
#' tibble(d = dist_uniform(0, 1)) %>%
#'   ggplot(aes(y = 0, xdist = d)) +
#'   stat_slab(aes(fill_ramp = after_stat(x)), fill = "blue") +
#'   scale_fill_ramp_continuous(from = "red", guide = guide_rampbar())
#'
#' # We can tell the guide what color to ramp to using the `to` argument:
#' tibble(d = dist_uniform(0, 1)) %>%
#'   ggplot(aes(y = 0, xdist = d)) +
#'   stat_slab(aes(fill_ramp = after_stat(x)), fill = "blue") +
#'   scale_fill_ramp_continuous(from = "red", guide = guide_rampbar(to = "blue"))
#'
#' @export
guide_rampbar = function(..., to = "gray65", available_aes = c("fill_ramp", "colour_ramp")) {
  guide = guide_colourbar(..., available_aes = available_aes)

  ggproto(
    "GuideRampbar", guide,
    params = c(list(to = to), guide$params),
    extract_decor = function(
      scale, aesthetic, nbin = 300, reverse = FALSE, alpha = NA,
      to = "gray65", ...
    ) {
      limits = scale$get_limits()
      bar = seq(limits[1], limits[2], length.out = nbin)
      if (length(bar) == 0) {
        bar = unique(limits)
      }
      bar = data_frame0(
        colour = scale$map(bar),
        value  = bar,
        .size  = length(bar)
      )
      if (reverse) {
        bar = bar[rev(seq_len(nrow(bar))), , drop = FALSE]
      }
      bar$colour = alpha(ramp_colours(to, bar$colour), alpha)
      bar
    }
  )
}
