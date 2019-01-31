aibs_dims <- function(res = "25nm") {
  if(res == "1nm") {
    c(13200, 8000, 11400)
  } else if(res == "25nm") {
    c(528, 320, 456)
  } else if(res == "200nm") {
    c(67, 41, 58)
  }
}
