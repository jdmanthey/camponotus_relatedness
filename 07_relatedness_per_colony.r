library(related)
library(ggplot2)

# read in genotypes  (modify this name as necessary for different colonies or datasets)
x <- read.table("filtered_100kbp.related", stringsAsFactors=F)

# input species name (e.g., herculeanus, laevigatus, or modoc)
species <- "laevigatus"

# input colony number (e.g., 1, 2, or 3)
colony_number <- 1

# define number of simulations
nsims <- 100

# simulations
# first, obtain overall allele freqs for each locus
# allow 5% variation of allele frequencies (i.e., a little randomness)
n_loci <- (ncol(x) - 1) / 2
alleles <- list()
allele_freqs <- list()
for(a in 1:n_loci) {
	alleles[[a]] <- c(x[,a * 2], x[,a * 2 + 1])
	af1 <- length(alleles[[a]][alleles[[a]] == 1]) / length(alleles[[a]])
	# add +/- 5% variation to allele frequencies (some stochasticity for small sample sizes)
	af1 <- af1 + sample(seq(from=-0.05, to=0.05, by=0.001), 1)
	# make sure the frequency is between 0.01 and 0.99
	if(af1 < 0.01) {
		af1 <- 0.01
	} else if (af1 > 0.99) {
		af1 <- 0.99
	}
	# change to integer on zero to one hundred scale
	af1 <- round(af1, digits=2) * 100
	af2 <- 100 - af1
	allele_freqs[[a]] <- c(rep(1, af1), rep(5, af2))
}

# output sim lists
offspring_sims <- list()
half_sibs <- list()
unrelated <- list()
# loop for simulations (this may take up to 30-60 minutes)
for(a in 1:nsims) {
	if(a %% 10 == 0) {
		writeLines(paste("Simulation ", a, " started.", sep=""))
	}
	
	# generate a haploid male
	male <- list()
	for(b in 1:n_loci) {
		male[[b]] <- sample(allele_freqs[[b]], 1)
	}
	male <- unlist(male)
	
	# sample a diploid female
	female_1 <- list()
	female_2 <- list()
	for(b in 1:n_loci) {
		female_1[[b]] <- sample(allele_freqs[[b]], 1)
		female_2[[b]] <- sample(allele_freqs[[b]], 1)
	}
	female_1 <- unlist(female_1)
	female_2 <- unlist(female_2)
	
	# create 1st offspring of the two parents
	offspring1 <- list()
	for(b in 1:length(female_1)) {
		offspring1[[b]] <- sort(c(male[b], sample(c(female_1[b], female_2[b]), 1)))
	}
	offspring1 <- unlist(offspring1)

	# create 2nd offspring of the two parents
	offspring2 <- list()
	for(b in 1:length(female_1)) {
		offspring2[[b]] <- sort(c(male[b], sample(c(female_1[b], female_2[b]), 1)))
	}
	offspring2 <- unlist(offspring2)
	
	# combine two offspring's data into one dataframe
	sim <- as.data.frame(cbind(c(paste("offspring1__", a, sep=""), paste("offspring2__", a, sep="")), rbind(offspring1, offspring2)))
	# make sure the first column of sim is character
	sim[,1] <- as.character(sim[,1])
	# add to offspring sims
	offspring_sims[[a]] <- sim
	
	# for half sib relationships with queen and two males mated
	# generate a second haploid male
	male2 <- list()
	for(b in 1:n_loci) {
		male2[[b]] <- sample(allele_freqs[[b]], 1)
	}
	male2 <- unlist(male2)

	# create 1st offspring of the one female and male 1
	halfsib1 <- list()
	for(b in 1:length(female_1)) {
		halfsib1[[b]] <- sort(c(male[b], sample(c(female_1[b], female_2[b]), 1)))
	}
	halfsib1 <- unlist(halfsib1)
	
	# create 2nd offspring of the one female, but mated to male 2
	halfsib2 <- list()
	for(b in 1:length(female_1)) {
		halfsib2[[b]] <- sort(c(male2[b], sample(c(female_1[b], female_2[b]), 1)))
	}
	halfsib2 <- unlist(halfsib2)
	
	# combine two halfsib's data into one dataframe
	sim <- as.data.frame(cbind(c(paste("halfsib1__", a, sep=""), paste("halfsib2__", a, sep="")), rbind(halfsib1, halfsib2)))
	# make sure the first column of sim is character
	sim[,1] <- as.character(sim[,1])
	# add to halfsib sims
	half_sibs[[a]] <- sim
	
	# unrelated individuals
	# sample a random genotype (x2) from the allele freqs
	random_1 <- list()
	random_2 <- list()
	for(b in 1:n_loci) {
		random_1[[b]] <- sample(allele_freqs[[b]], 2)
		random_2[[b]] <- sample(allele_freqs[[b]], 2)
	}
	random_1 <- unlist(random_1)
	random_2 <- unlist(random_2)
	
	# combine two randoms' data into one dataframe
	sim <- as.data.frame(cbind(c(paste("unrelated1__", a, sep=""), paste("unrelated2__", a, sep="")), rbind(random_1, random_2)))
	# make sure the first column of sim is character
	sim[,1] <- as.character(sim[,1])
	# add to unrelated sims
	unrelated[[a]] <- sim
}

# add all real and simulated data into a single data frame for relatedness estimates
total <- x
offspring_sims2 <- do.call("rbind", offspring_sims)
half_sibs2 <- do.call("rbind", half_sibs)
unrelated2 <- do.call("rbind", unrelated)
total <- rbind(total, offspring_sims2, half_sibs2, unrelated2)

# clean up objects no longer needed and clean up garbage
rm(offspring_sims2, half_sibs2, unrelated2, offspring_sims, half_sibs, unrelated)

# measure relatedness of all real and simulated individuals (this may take up to 30-60 minutes)
total_relate <- coancestry(total, lynchli=2, wang=2)

# extract point estimates of relatedness for each grouping
# real data
real_data_relatedness <- total_relate$relatedness[total_relate$relatedness$group == "C-C-",]
real_data_95CI <- total_relate$relatedness.ci95[total_relate$relatedness.ci95$group == "C-C-",]

# full sister simulations
full_sister_relatedness <- total_relate$relatedness[total_relate$relatedness$group == "ofof",]
full_sister_relatedness <- full_sister_relatedness[sapply(strsplit(full_sister_relatedness[,2], "__"), "[[", 2) == sapply(strsplit(full_sister_relatedness[,3], "__"), "[[", 2), ]

# half sister simulations
half_sister_relatedness <- total_relate$relatedness[total_relate$relatedness$group == "haha",]
half_sister_relatedness <- half_sister_relatedness[sapply(strsplit(half_sister_relatedness[,2], "__"), "[[", 2) == sapply(strsplit(half_sister_relatedness[,3], "__"), "[[", 2), ]

# unrelated individuals simulations
unrelated_relatedness <- total_relate$relatedness[total_relate$relatedness$group == "unun",]
unrelated_relatedness <- unrelated_relatedness[sapply(strsplit(unrelated_relatedness[,2], "__"), "[[", 2) == sapply(strsplit(unrelated_relatedness[,3], "__"), "[[", 2), ]


# save the work
save.image(paste(species, "__", colony_number, "__relatedness.RData", sep=""))

# make a merged data frame for boxplots of simulations
full_sister_related <- data.frame(Relationship=as.character(rep("Full Sister", nrow(full_sister_relatedness)*2)), Measurement=as.character(c(rep("Wang (2002)", nrow(full_sister_relatedness)), rep("Li et al. (1993)", nrow(full_sister_relatedness)))), Relatedness=as.numeric(c(full_sister_relatedness$wang, full_sister_relatedness$lynchli)))
half_sister_related <- data.frame(Relationship=as.character(rep("Half Sister", nrow(half_sister_relatedness)*2)), Measurement=as.character(c(rep("Wang (2002)", nrow(half_sister_relatedness)), rep("Li et al. (1993)", nrow(half_sister_relatedness)))), Relatedness=as.numeric(c(half_sister_relatedness$wang, half_sister_relatedness$lynchli)))
unrelated_sister_related <- data.frame(Relationship=as.character(rep("Unrelated", nrow(unrelated_relatedness)*2)), Measurement=as.character(c(rep("Wang (2002)", nrow(unrelated_relatedness)), rep("Li et al. (1993)", nrow(unrelated_relatedness)))), Relatedness=as.numeric(c(unrelated_relatedness$wang, unrelated_relatedness$lynchli)))

# combine the three into one
total_related <- rbind(full_sister_related, half_sister_related, unrelated_sister_related)

# make a boxplot
ggplot(total_related, aes(x=Relationship, y=Relatedness, fill=Measurement)) + geom_boxplot()

# save a pdf of the boxplot (change the name as necessary)
pdf(file=paste(species, "__", colony_number, "__simboxplot.pdf", sep=""), width=5, height=7)
ggplot(total_related, aes(x=Relationship, y=Relatedness, fill=Measurement)) + geom_boxplot()
dev.off()


# combine the real data into a nice data matrix and save the table
real_data_output <- data.frame(Ind1=as.character(real_data_relatedness$ind1.id),
							   Ind2=as.character(real_data_relatedness$ind2.id),
							   Species=as.character(species),
							   Colony=as.character(colony_number),
							   Wang=as.numeric(real_data_relatedness$wang),
							   Wang_low=as.numeric(real_data_95CI$wang.low),
							   Wang_high=as.numeric(real_data_95CI$wang.high),
							   Li=as.numeric(real_data_relatedness$lynchli),
							   Li_low=as.numeric(real_data_95CI$lynchli.low),
							   Li_high=as.numeric(real_data_95CI$lynchli.high))
# print the matrix to look at
real_data_output
# write the matrix to table
write.table(real_data_output, file=paste(species, "__", colony_number, "__relatedness.txt", sep=""), sep="\t",
			quote=F, col.names=T, row.names=F)


