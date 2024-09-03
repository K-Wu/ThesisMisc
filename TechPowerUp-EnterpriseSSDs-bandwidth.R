#
# SPEC-memory.R,  4 Oct 20
# Data from:
# spec.org
# SPEC
#
# Example from:
# Evidence-based Software Engineering: based on the publicly available data
# Derek M. Jones
#
# TAG SPEC memory_capacity
setwd("D:/impact-repos/ThesisMisc")
source("ESEUR_config.r")


library("quantreg")
library(dplyr)

pal_col=rainbow(2)


sp=read.csv("techpowerup_enterprise_ssds_bandwidth.csv", as.is=TRUE)
# mac=read.csv("cpu2017-results-20240820-201225.csv", as.is=TRUE)

# mac$date=as.Date(paste0("01 jan-", mac$Year), format="%d %b-%Y")
sp$date=as.Date(sp$released_normalized, format="%m/%d/%Y")

start_date=as.Date("2016-01-01") # Remove a couple of wrong dates
end_date=as.Date("2024-10-01") 
sp=subset(sp, start_date < date & end_date > date)


# q=sp[which(sp$meg_mem < 40), ]
# w=sp[which(is.na(sp$meg_mem) & !is.na(sp$date)), ]

dev.off()

plot(sp$date, sp$Sequential.Write.MBsec, log="y", col=pal_col[2],
     yaxt="n",
     xaxs="i",
     xlim=c(start_date, end_date), ylim=c(100, 1e4),
     xlab="Release date", ylab="Sequential Write (MB/s)")

mem_vals=c("100", "1000", "10000","100000")
axis(2, at=as.numeric(mem_vals), label=mem_vals)

# lines(loess.smooth(sp$date, sp$Sequential.Write.MBsec, span=0.3), col="yellow")
# 
# loess_mod=loess(log(sp$Sequential.Write.MBsec) ~ sp$date, span=0.3)
# loess_pred=predict(loess_mod)
# lines(sp$date, exp(loess_pred), col=loess_col)

# sp_mod=glm(log(Sequential.Write.MBsec) ~ date, data=sp)
# summary(sp_mod)
# 
u_date=c(start_date, unique(sp$date))
# pred=predict(sp_mod, newdata=data.frame(date=u_date))
# lines(u_date, exp(pred), col="red")


#rq98_mod=rq(log(Sequential.Write.MBsec) ~ date, data=sp, tau=0.98) # tau is the quantile
#pred=predict(rq98_mod, newdata=data.frame(date=u_date))
#lines(u_date, exp(pred), col=pal_col[1])

rq95_mod=rq(log(Sequential.Write.MBsec) ~ date, data=sp, tau=0.95) # tau is the quantile
pred_95=predict(rq95_mod, newdata=data.frame(date=u_date))
lines(u_date, exp(pred_95), col=pal_col[1])

rq50_mod=rq(log(Sequential.Write.MBsec) ~ date, data=sp, tau=0.50) # tau is the quantile
# summary(rq50_mod)
# 
# log(2)/coef(rq50_mod)[2] # doubling time in days

pred_50=predict(rq50_mod, newdata=data.frame(date=u_date))
lines(u_date, exp(pred_50), col=pal_col[1])


# points(mac$date, mac$RAM/1024, col="blue", pch="o")

# mac95_mod=rq(log(RAM) ~ date, data=mac, tau=0.05) # tau is the quantile
# summary(mac95_mod)
# 
# log(2)/coef(mac95_mod)[2]

