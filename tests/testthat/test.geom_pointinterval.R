# Tests for interval geoms
#
# Author: mjskay
###############################################################################

library(dplyr)
library(tidyr)



# use a subset of RankCorr so tests are faster
data(RankCorr_u_tau, package = "ggdist")
RankCorr_u_tau = RankCorr_u_tau %>%
  filter(i %in% 1:3, .iteration %in% 1:50) %>%
  group_by(i)

test_that("horizontal grouped pointintervals work", {
  skip_if_no_vdiffr()


  vdiffr::expect_doppelganger("grouped pointintervals (h)",
    RankCorr_u_tau %>%
      median_hdci(.width = c(.66, .95)) %>%
      ggplot(aes(y = i, x = u_tau, xmin = .lower, xmax = .upper)) +
      geom_pointinterval(show.legend = TRUE) +
      theme_ggdist()
  )

  vdiffr::expect_doppelganger("grouped pointintervals (h, stat)",
    RankCorr_u_tau %>%
      ggplot(aes(y = factor(i), x = u_tau)) +
      stat_pointinterval(
        .width = c(.66, .95),
        arrow = arrow(angle = 45, length = unit(4, "pt"), type = "closed", ends = "both")
      )
  )

  vdiffr::expect_doppelganger("grouped pointintervals (h, reverse order)",
    RankCorr_u_tau %>%
      median_qi(.width = c(.66, .95)) %>%
      ggplot(aes(y = i, x = u_tau, xmin = .lower, xmax = .upper)) +
      geom_pointinterval()
  )

  vdiffr::expect_doppelganger("grouped pointintervals (h, stat, reverse order)",
    RankCorr_u_tau %>%
      ggplot(aes(y = factor(i), x = u_tau)) +
      stat_pointinterval(.width = c(.66, .95))
  )
})

test_that("grouped pointintervals work", {
  skip_if_no_vdiffr()


  forward_plot = RankCorr_u_tau %>%
    mean_qi(.width = c(.66, .95)) %>%
    ggplot(aes(x = i, y = u_tau, ymin = .lower, ymax = .upper)) +
    geom_pointinterval(interval_size_range = c(1,4), fatten_point = 3)

  vdiffr::expect_doppelganger("grouped pointintervals with custom fatten", forward_plot)

  forward_plot = RankCorr_u_tau %>%
    mean_qi(.width = c(.66, .95)) %>%
    ggplot(aes(
      x = i, y = u_tau, ymin = .lower, ymax = .upper,
      interval_size = fct_rev_(ordered(.width))
    )) +
    geom_pointinterval(point_size = 3)

  vdiffr::expect_doppelganger("grouped, with interval_size and legend", forward_plot)

  stat_forward_plot = RankCorr_u_tau %>%
    ggplot(aes(x = i, y = u_tau)) +
    stat_pointinterval(.width = c(.66, .95))

  vdiffr::expect_doppelganger("grouped pointintervals (stat)", stat_forward_plot)

})

test_that("orientation detection on pointintervals works", {
  skip_if_no_vdiffr()


  p = tibble(
    v = c(1, 2),
    l = c(0, 1),
    u = c(4, 5),
    g = c("a", "b")
  ) %>%
    ggplot()

  vdiffr::expect_doppelganger("vertical, orientation detection",
    p + geom_pointinterval(aes(x = g, y = v, ymin = l, ymax = u), orientation = NA)
  )

  vdiffr::expect_doppelganger("horizontal, orientation detection",
    p + geom_pointinterval(aes(y = g, x = v, xmin = l, xmax = u), orientation = NA)
  )

  vdiffr::expect_doppelganger("vertical, orientation detection plus dodge",
    p + geom_pointinterval(aes(color = g, y = v, ymin = l, ymax = u), orientation = NA, position = "dodge")
  )

  vdiffr::expect_doppelganger("horizontal, orientation detection, dodge",
    p + geom_pointinterval(aes(color = g, x = v, xmin = l, xmax = u), orientation = NA, position = "dodge")
  )

})

test_that("missing data is handled correctly", {
  skip_if_no_vdiffr()


  p = tibble(
    x = c(1,NA,1),
    xmin = c(NA,0,0),
    xmax = c(NA,2,2),
    y = c("a","b",NA)
  ) %>%
    ggplot(aes(x = x, xmin = xmin, xmax = xmax, y = y))

  expect_warning(
    vdiffr::expect_doppelganger("geom_pointinterval na.rm = FALSE",
      p + geom_pointinterval(na.rm = FALSE)
    ),
    "Removed 1 row.+missing values"
  )

  vdiffr::expect_doppelganger("geom_pointinterval na.rm = TRUE",
    p + geom_pointinterval(na.rm = TRUE)
  )

})

test_that("dist aesthetic can be NULLed out", {
  skip_if_no_vdiffr()


  hist_df = tibble(
    geom = "histinterval",
    x = qnorm(ppoints(100), 4, 1),
    dist = NA
  )

  vdiffr::expect_doppelganger("dist aesthetic can be NULLed out",
    hist_df %>%
      ggplot(aes(y = geom, dist = dist)) +
      stat_pointinterval(aes(x = x, y = "pointinterval", dist = NULL))
  )
})


# error on missing xmin/ymin/xmax/ymax ------------------------------------

test_that("missing min/max aesthetics are caught", {
  expect_error(
    print(newpage = FALSE,
      ggplot(data.frame(x = 1), aes(x = x)) +
        geom_pointinterval()
    ),
    "You did not specify xmin or xmax aesthetics"
  )
})
