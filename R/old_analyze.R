#' Correction of Genomes in R
#'
#' Software for the Examination of Multiple Correction Methodologies in Accurate Genomic Environments
#'
#' @param i Index 1
#' @param j Index 2
#' @param k Index 3
#'
#' @return Output file at container.
#'


analyze_old <- function(i = double(), j = double()){

	# just for now to grab the R functions

message("Loading files, this is temporary...")

	setwd("/home/hpc2862/repos/coR-ge/R")
	for(file in c("gen2r.R", "rand0.R", "rand.R", "sim.gen.R")) source(file)

message("Loading packages...")

	if (!require("pacman")) install.packages("pacman", "http://cran.utstat.utoronto.ca/")
	library(pacman)
	p_load(data.table, dplyr, magrittr)

	path <- paste0("/scratch/hpc2862/CAMH/perm_container/container_",i,"_",j,"/")

	# just as a safety measure
	setwd(path)

message("Deleting unneeded files...")

	list.files(path)[!grepl("controls.gen", list.files(path))] %>% file.remove

	# for(k in 1:5){
	# 	#clear out excess files
	# 	system(paste0("rm chr1_block_",i,"_perm_",j,"_k_",k,".cases.gen; ",
	# 		"rm chr1_block_",i,"_perm_",j,"_k_",k,".cases.haps;",
	# 		"rm chr1_block_",i,"_perm_",j,"_k_",k,".cases.sample;",
	# 		"rm chr1_block_",i,"_perm_",j,"_k_",k,".cases.summary;",
	# 		"rm chr1_block_",i,"_perm_",j,"_k_",k,".cases.legend;",
	# 		"rm chr1_block_",i,"_perm_",j,"_k_",k,".controls.sample;",
	# 		"rm chr1_block_",i,"_perm_",j,"_k_",k,".controls.haps;",
	# 		"rm chr1_block_",i,"_perm_",j,"_k_",k,".controls.summary;",
	# 		"rm chr1_block_",i,"_perm_",j,"_k_",k,".controls.legend"))}


	setwd("/home/hpc2862/Raw_Files/CAMH/1kg_hapmap_comb/hapmap3_r2_plus_1000g_jun2010_b36_ceu/test_mar_30")


messages("Reading in genotype files...")
	# this replaces reading individually
	## THIS HASNT BEEN TESTED YET (March 6)
	for(k in 1:5){
		if(k == 1){
			fread(paste0(path, "chr1_block_", i, "_perm_", j, "_k_", k, ".controls.gen"), h = F, sep = " ") %>% as.data.frame() -> gen
		} else if(k != 1){
			fread(paste0(path, "chr1_block_", i, "_perm_", j, "_k_", k, ".controls.gen"), h = F, sep = " ") %>% as.data.frame() %>% select(.,-V1:-V5) %>% cbind(gen, .) -> gen
		}
	}

	colnames(gen) <- paste0("V",1:ncol(gen))
	## Select SNPs
	# Based on MAF 0.05 - 0.5, uniform

	summary <- fread("/scratch/hpc2862/CAMH/perm_container/snp_summary2.out", h = T, sep = " ")
	snps <- NULL

	# add in each 1000 sample sequentially

message("Selecting random SNPs...")

	for(i in 1:max(summary$k)){

		summary %>% filter(k==i) %>% sample_n(1000) %>% select(rsid, chromosome, position, all_maf, k) %>% rbind(snps, .) -> snps

	}


	colnames(snps) <- c("rsid", "chromosomes", "V3", "all_maf", "k")

	comb <- merge(gen, snps, by = "V3")
	comb <- as.data.frame(comb)

	## eliminate overlap

	comb$rsid <- NULL; comb$chromosomes <- NULL; comb$all_maf <- NULL; comb$k <- NULL


message("Converting from Oxford format to R format...")
	#translate to R
	combR <- gen2r(genfile = comb, local = TRUE)

	## add row names to this from the sample file

	samp <- vector()
	n_people <- nrow(combR) ## make sure this is right...
	ID_1 <- paste0("ID_1_", 1:n_people)
	ID_2 <- paste0("ID_2_", 1:n_people)
	samp <- cbind(ID_2, ID_1)
	samp <- as.data.frame(samp)
	samp$missing <- 0

	row.names(combR) <- samp$ID_1

message("Calculating phenotypes...")

	###calculate phenotypes HERE

	pheno <- vector()
	WAS <- vector()
	Zscore <- vector()

	## generate variance residuals

	sd2 <- rand(n = ncol(combR), sum = 0.45)

	results <- vector()
	results <- as.data.frame(results)
	b <- vector()
	snps <- as.data.frame(snps)
	## calulate beta

	for(i in 1:ncol(combR)){
	  b[i] <- rand0()*sqrt(sd2[i]/(2*snps[i,"all_maf"]*(1-snps[i,"all_maf"])))
	}

	## calculate WAS

	for(i in 1:nrow(combR)){
	  for(j in 1:ncol(combR)){
		combR[i,j] <- combR[i,j]*b[j] - b[j]*snps[j,"all_maf"]
	  }
	}

	WAS <- rowSums(combR)
	Z <- vector()

	for(i in 1:length(WAS)){
	  Z[i] <- WAS[i] + rnorm(1, 0, sd = sqrt(0.55))
	}

	samp$Z <- Z

	var <- data.frame(0, 0, 0, "C")
	samp$Z <- as.character(samp$Z)
	colnames(var) <- colnames(samp)
	samp <- rbind(var, samp)

	colnames(var) <- colnames(samp)
	samp <- rbind(var, samp)

	colnames(var) <- colnames(samp)
	samp <- rbind(var, samp)

message("Writing out temp files")

	write.table(samp, paste0(path,"phen_test.sample"), quote = FALSE, row.names=F, col.names = T, sep = "\t")
	write.table(gen, paste0(path,"gen_test.gen"), quote = FALSE, row.names = F, col.names = F)
	write.table(snps, paste0(path,"snptlist.txt"), quote = FALSE, row.names=F, col.names = T, sep = "\t")

	for(k in 1:5){
	system(paste0("rm chr1_block_",i, "_perm_", j,"_k_", k, ".controls.gen"))
	}

	#gtool step
	system(paste0("/home/hpc2862/Programs/binary_executables/gtool -G --g gen_test.gen --s phen_test.sample --ped ", i, "_", j, "_out.ped --map ", i, "_", j, "_out.map --phenotype Z"))

	system("rm gtool.log")
	system("rm gen_test.gen")
	system("rm phen_test.sample")

	system(paste0("/home/hpc2862/Programs/binary_executables/plink --noweb --file ",path, i, "_", j, "_out --assoc --allow-no-sex --out ", path, "plink"))

	system("rm plink.log")
	system("rm plink.nosex")
	system(paste0("rm ", i, "_", j, "_out.ped"))
	system(paste0("rm ", i, "_", j, "_out.map"))


message("Correct and report...")
	# this is now correct and report.R

	setwd(path)
message("Reading in files...")

	snps <- fread("snptlist.txt")

	q <- read.table("plink.qassoc", h = T)

	summary <- read.table("/scratch/hpc2862/CAMH/perm_container/snp_summary2.out", h = T)
	summary <- summary[ ! summary$rsid %in% snps$rsid] ##remove any overlaps

	colnames(snps) <- c("SNP", "CHR", "BP", "MAF", "k")

	snps_back <- snps
	snps <- snps$SNP

	#q %>% mutate(real = SNP %in% snps[]) -> q2

	##HARD CODED THIS IS BAD

message("Select SNPs and correct...")
warning("This has to be replaced with a more standardized version.")

	n_snps <- c(1,2,3,4)

	for(n in n_snps){

		q %>% mutate(real = SNP %in% snps_back$SNP[snps_back$k == n]) -> q2

		summary %>% filter(k==i) %>% sample_n(3000) %>% select(rsid, chromosome, position, all_maf, k) -> fake_snps

		#summary %>% filter(all_maf > 0.05) %>% filter(all_maf < 0.5) %>% sample_n(n) %>% select(rsid, chromosome, position, all_maf) -> fake_snps

		colnames(fake_snps) <- c("SNP", "CHR", "BP", "MAF", "k")

		q2 %>% mutate(fake = SNP %in% fake_snps$SNP) -> q3

		stratum_1 <- rbind(q3[q3$real == TRUE,], q3[q3$fake == TRUE,])
		minus_stratum <- q3[q3$real == FALSE & q3$fake == FALSE,]
		agg <- q3

		#adjust

		stratum_1 %>% mutate(p.adj = p.adjust(P, method = "BH")) -> stratum_1
		minus_stratum %>% mutate(p.adj = p.adjust(P, method = "BH")) -> minus_stratum

		stratum_1 %>% mutate(p.adj = p.adjust(P, method = "bonferroni")) -> b_stratum_1
		minus_stratum %>% mutate(p.adj = p.adjust(P, method = "bonferroni")) -> b_minus_stratum


		agg %>% mutate(p.adj = p.adjust(P, method = "BH")) -> agg

		agg %>% mutate(p.adj = p.adjust(P, method = "bonferroni")) -> b_agg

		A_TP <- sum(agg$real == TRUE & agg$p.adj < 0.05 & !is.na(agg$p.adj), na.exclude = TRUE)
		A_FP <- sum(agg$real == FALSE & agg$p.adj < 0.05 & !is.na(agg$p.adj), na.exclude = TRUE)
		A_TN <- sum(agg$real == FALSE & !(agg$p.adj < 0.05) & !is.na(agg$p.adj), na.exclude = TRUE)
		A_FN <- sum(agg$real == TRUE & !(agg$p.adj < 0.05) & !is.na(agg$p.adj), na.exclude = TRUE)

		# Ab_TP <- sum(b_agg$real == TRUE & b_agg$p.adj < 0.05 & !is.na(agg$p.adj), na.exclude = TRUE)
		# Ab_FP <- sum(b_agg$real == FALSE & b_agg$p.adj < 0.05 & !is.na(agg$p.adj), na.exclude = TRUE)
		# Ab_TN <- sum(b_agg$real == FALSE & !(b_agg$p.adj < 0.05) & !is.na(agg$p.adj), na.exclude = TRUE)
		# Sb_FN <- sum(b_stratum_1$real == TRUE && !(b_stratum_1$p.adj < 0.05) & !is.na(agg$p.adj), na.exclude = TRUE) + sum(b_minus_stratum$real == TRUE & !(b_minus_stratum$p.adj < 0.05), na.exclude = TRUE)

		S_TP <- sum(stratum_1$real == TRUE & stratum_1$p.adj < 0.05 & !is.na(stratum_1$p.adj), na.exclude = TRUE, na.exclude = TRUE)
		S_FP <- sum(stratum_1$real == FALSE & stratum_1$p.adj < 0.05 & !is.na(stratum_1$p.adj), na.exclude = TRUE, na.exclude = TRUE) + sum(minus_stratum$real == FALSE & minus_stratum$p.adj < 0.05 & !is.na(minus_stratum$p.adj), na.exclude = TRUE)
		S_TN <- sum(stratum_1$real == FALSE & !(stratum_1$p.adj < 0.05) & !is.na(stratum_1$p.adj), na.exclude = TRUE) + sum(minus_stratum$real == FALSE & !(minus_stratum$p.adj < 0.05) & !is.na(minus_stratum$p.adj), na.exclude = TRUE)
		S_FN <- sum(stratum_1$real == TRUE & !(stratum_1$p.adj < 0.05) & !is.na(stratum_1$p.adj), na.exclude = TRUE) + sum(minus_stratum$real == TRUE & !(minus_stratum$p.adj < 0.05) & !is.na(minus_stratum$p.adj), na.exclude = TRUE)

		# Sb_TP <- sum(b_stratum_1$real == TRUE & b_stratum_1$p.adj < 0.05 & !is.na(stratum_1$p.adj), na.exclude = TRUE) + sum(b_minus_stratum$real == TRUE & b_minus_stratum$p.adj < 0.05 & !is.na(minus_stratum$p.adj), na.exclude = TRUE)
		# Sb_FP <- sum(b_stratum_1$real == FALSE & b_stratum_1$p.adj < 0.05 & !is.na(stratum_1$p.adj), na.exclude = TRUE) + sum(b_minus_stratum$real == FALSE & b_minus_stratum$p.adj < 0.05 & !is.na(minus_stratum$p.adj), na.exclude = TRUE)
		# Sb_TN <- sum(b_stratum_1$real == FALSE & !(b_stratum_1$p.adj < 0.05) & !is.na(stratum_1$p.adj), na.exclude = TRUE) + sum(b_minus_stratum$real == FALSE & !(b_minus_stratum$p.adj < 0.05) & !is.na(minus_stratum$p.adj), na.exclude = TRUE)
		# Sb_FN <- sum(b_stratum_1$real == TRUE & !(b_stratum_1$p.adj < 0.05) & !is.na(stratum_1$p.adj), na.exclude = TRUE) + sum(b_minus_stratum$real == TRUE & !(b_minus_stratum$p.adj < 0.05) & !is.na(minus_stratum$p.adj), na.exclude = TRUE)

		fdr <- A_FP / (A_TP + A_FP)
		sfdr <- S_FP / (S_TP + S_FP)

message("Writing output and cleaning up...")

		write <- cbind(n, A_TP,A_FP,A_TN,A_FN,S_TP,S_FP,S_TN,S_FN, fdr, sfdr)
		write.table(write, file = "/scratch/hpc2862/CAMH/perm_container/out_DONTDELETE_files/results_cluster_new.txt", append = T, quote = F, sep = " ", row.name = F, col.name = F)
	}



#this is the end of the function
}
