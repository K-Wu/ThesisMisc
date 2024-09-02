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


meg_mem=function(lx)
{
dev_t_size=function(n_dev, dev_size)
   {
   n_dev=as.integer(n_dev)
   x_unit=substring(dev_size, nchar(dev_size)-1)
   x_num=as.integer(substr(dev_size, 1, nchar(dev_size)-2))
   ifelse(x_unit == "TB", return(n_dev*x_num*1024*1024),
   ifelse(x_unit == "GB", return(n_dev*x_num*1024),
	ifelse(x_unit == "MB", return(n_dev*x_num),
	ifelse(x_unit == "KB", return(n_dev*x_num/1024),
	return(NA)))))
   }

mult_x=function(x_str)
   {
   t=unlist(strsplit(x_str, "X"))
   return(dev_t_size(t[1], t[2]))
   }


num=toupper(lx[1])
ifelse(grepl("X", num), return(mult_x(num)), NA)

unit=toupper(substr(lx[2], 1, 2))
x_val=toupper(lx[3])
x_unit=substring(x_val, nchar(x_val)-1)
x_num=as.integer(substr(x_val, 1, nchar(x_val)-2))
x4_unit=toupper(lx[4])

n_units=substring(num, nchar(num)-1)
ifelse(n_units == "GB",
		return(as.integer(substr(num, 1, nchar(num)-2))*1024),
	ifelse(n_units == "MB",
		return(as.integer(substr(num, 1, nchar(num)-2))),
	ifelse(n_units == "KB",
		return(as.integer(substr(num, 1, nchar(num)-2))/1024),
	NA)))

num=as.integer(num)
ifelse(unit == "X", # 4 x 1024MB ECC DDR2-667 SDRAM
	ifelse(x_unit == "GB", return(num*x_num*1024),
	ifelse(x_unit == "MB", return(num*x_num),
	ifelse(x_unit == "KB", return(num*x_num/1024),
		# 2 x 1024 MB DDR333 SDRAM
		ifelse(x4_unit == "GB", return(num*as.integer(x_val)*1024),
		ifelse(x4_unit == "MB", return(num*as.integer(x_val)),
		ifelse(x4_unit == "KB", return(num*as.integer(x_val)/1024),
		NA)))))),
	NA)

return(ifelse(is.na(unit), num, # otherwise, if unit == NA, NA is returned!
	ifelse(unit == "TB", num*1024*1024,
	ifelse(unit == "GB", num*1024,
	ifelse(unit == "MB", num,
	ifelse(unit == "KB", num/1024,
	NA))))))
}


sp=read.csv("cpu2017-results-20240820-201225.csv", as.is=TRUE)
# mac=read.csv("cpu2017-results-20240820-201225.csv", as.is=TRUE)

# mac$date=as.Date(paste0("01 jan-", mac$Year), format="%d %b-%Y")
sp$date=as.Date(paste0("01 ", sp$Test.Date), format="%d %b-%Y")

start_date=as.Date("2016-01-01") # Remove a couple of wrong dates
end_date=as.Date("2024-10-01") 
sp=subset(sp, start_date < date & end_date > date)


t=strsplit(gsub("\\(", " ", gsub(",", "", sp$Memory)), " ")
sp$meg_mem=unlist(lapply(t, meg_mem))

# Assume 'naked' values are in GB after this date
gig_date=as.Date("2004-01-01")

sp$meg_mem=ifelse((sp$date > gig_date) & (sp$meg_mem < 513),
					sp$meg_mem*1024, sp$meg_mem)

sp$gig_mem=sp$meg_mem/1024

sp$X..Chips=max(sp$X..X..Chips,1)
sp$gig_mem_per_socket=sp$gig_mem/sp$X..Chips

sp=distinct(select(sp,date,Hardware.Vendor.,System,X..Cores,gig_mem_per_socket))

# q=sp[which(sp$meg_mem < 40), ]
# w=sp[which(is.na(sp$meg_mem) & !is.na(sp$date)), ]

dev.off()

plot(sp$date, sp$gig_mem_per_socket, log="y", col=pal_col[2],
	yaxt="n",
	xaxs="i",
	xlim=c(start_date, end_date), ylim=c(10, 1e4),
	xlab="Test date", ylab="Memory per socket (GB)")

mem_vals=c("0.01", "0.1", "1", "10", "100", "1000", "10000")
axis(2, at=as.numeric(mem_vals), label=mem_vals)

# lines(loess.smooth(sp$date, sp$gig_mem_per_socket, span=0.3), col="yellow")
# 
# loess_mod=loess(log(sp$gig_mem_per_socket) ~ sp$date, span=0.3)
# loess_pred=predict(loess_mod)
# lines(sp$date, exp(loess_pred), col=loess_col)

# sp_mod=glm(log(gig_mem_per_socket) ~ date, data=sp)
# summary(sp_mod)
# 
u_date=c(start_date, unique(sp$date))
# pred=predict(sp_mod, newdata=data.frame(date=u_date))
# lines(u_date, exp(pred), col="red")


#rq98_mod=rq(log(gig_mem_per_socket) ~ date, data=sp, tau=0.98) # tau is the quantile
#pred=predict(rq98_mod, newdata=data.frame(date=u_date))
#lines(u_date, exp(pred), col=pal_col[1])

rq95_mod=rq(log(gig_mem_per_socket) ~ date, data=sp, tau=0.95) # tau is the quantile
pred_95=predict(rq95_mod, newdata=data.frame(date=u_date))
lines(u_date, exp(pred_95), col=pal_col[1])

rq50_mod=rq(log(gig_mem_per_socket) ~ date, data=sp, tau=0.50) # tau is the quantile
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

