#Random functions
library()

#define a set of colors
colors <- RColorBrewer::brewer.pal(n = 9, name = "Dark2")

#make a color range using colorRampPalette()
#the object now becomes a function which to call a number on
color_range <- colorRampPalette(colors)

plot(rnorm(10),col = color_range(9), pch = 15)

ChickWeight %>%
ggplot(aes(x = Time, y = weight, color = Diet))+
  geom_point(color = 'black')+
  stat_smooth(method = "lm", se = F)+
  stat_quantile(quantiles = 0.5, linetype = 2)
