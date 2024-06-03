library(tidyverse)
library(corrplot)
library(grid)

## read data files
df <- read.csv("data/data.csv", row.names = 1, check.names = FALSE)
group <- read.csv("data/group.csv", check.names = FALSE)


## set colors
colbar <- colorRampPalette(c("#67001F", "#B2182B", "#D6604D", "#F4A582",
                           "#FDDBC7", "#FFFFFF", "#D1E5F0", "#92C5DE",
                           "#4393C3", "#2166AC", "#053061"))

coltext <- c("#000000", "#A69900", "#8F1D00", "#056258", "#6A478F")

group$color <- coltext[factor(group$order, 
                              levels = c("microConj", "priConjSum", "primarySum", "secConjSum", "secondarySum"))]


## correlation heatmap
df_log <- log10(df + 0.000001)
corr <- cor(df_log, method = "pearson")

variable_ordering <- corrplot(corr, type = "upper", order = "hclust")$corrPos$xName %>% unique
variable_color <- group[match(variable_ordering, group$`Bile acid`),]$color


dev.new(width=12, height=8, unit = "in")
layout(matrix(c(2,1), 1), widths = c(1,3))

corrplot(corr, type = "upper", order = "hclust",
         col = rev(colbar(200)), 
         cl.pos = "n",
         tl.col = variable_color, tl.cex = 0.7,
         mar = c(0, 0, 0, 2),
         tl.srt = 60)



## Abbreviated/summarised correlations (insert in main figure)
df_summary <- df %>%
  mutate(primarySum = rowSums(across(group[group$order == "primarySum", ]$`Bile acid`))) %>%
  mutate(priConjSum = rowSums(across(group[group$order == "priConjSum", ]$`Bile acid`))) %>%
  mutate(secondarySum = rowSums(across(group[group$order == "secondarySum", ]$`Bile acid`))) %>%
  mutate(secConjSum = rowSums(across(group[group$order == "secConjSum", ]$`Bile acid`))) %>%
  mutate(microConj = rowSums(across(group[group$order == "microConj", ]$`Bile acid`))) %>%
  select(primarySum, priConjSum, secondarySum, secConjSum, microConj) %>%
  mutate_all(~ log10(. + 0.000001)) %>%
  as.matrix

colnames(df_summary) <- c("3", "2", "5", "4", "1")
corr_summary <- cor(df_summary, method = "pearson")

corrplot(corr_summary, type = "upper", order='alphabet',
         col = rev(colbar(200)),
         cl.pos = "b", cl.ratio = 0.4, cl.cex = 0.6,
         tl.col = "black", tl.cex = 1, tl.offset = 0.8,
         tl.srt = 0, diag = FALSE,
         mar = c(3, 3, 3, 0))

p = recordPlot() 



## Barblot of concentration
abs_conc <- group[group$order != "microConj", ]$`Bile acid`

conc_barplot <- df %>%
  rownames_to_column() %>%
  pivot_longer(cols = (!"rowname"), names_to = "bile_acid", values_to = "concentration") %>%
  group_by(bile_acid) %>%
  summarise(mean_ba = log10(mean(concentration, na.rm = T))) %>%
  mutate(bile_acid = factor(bile_acid, levels = rev(variable_ordering)), 
         color = ifelse(bile_acid %in% abs_conc, "green", "purple"))

p3 <- ggplot(conc_barplot, aes(y = bile_acid, x = mean_ba, fill = color)) +
  geom_col() +
  scale_fill_manual(values = c("#00A075", "#440154FF"), guide = "none") +
  scale_x_continuous(expand=c(0,0), breaks = seq(0,6,2), limits = c(0,6)) +
  labs(x = "", y = "") +  
  theme_classic(base_size = 20) +
  theme(panel.background = element_rect(fill = "transparent"), 
        plot.background = element_rect(fill = "transparent", color= NA ), 
        plot.margin = margin(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.x = element_text(color = "black", size = 12))


## annotation
anno <- data.frame(a=c(1:8),
                   b=c(1:4))

p4 <- ggplot(anno, aes(a,b)) +
  geom_rect(aes(xmin=0,xmax=0.3,ymin=2.0,ymax=2.3), fill = "#000000")+
  geom_rect(aes(xmin=0,xmax=0.3,ymin=1.5,ymax=1.8), fill = "#A69900")+
  geom_rect(aes(xmin=0,xmax=0.3,ymin=1.0,ymax=1.3), fill = "#8F1D00")+
  geom_rect(aes(xmin=0,xmax=0.3,ymin=0.5,ymax=0.8), fill = "#056258")+
  geom_rect(aes(xmin=0,xmax=0.3,ymin=0,ymax=0.3), fill = "#6A478F")+
  annotate(geom='text',x=3.0,y=2.15,label="1. Microbially conjugated bile acids",size=4,color="#000000")+
  annotate(geom='text',x=2.4,y=1.6,label= expression(paste("2. 1",degree," conjugated bile acids",sep="")),size=4,color="#A69900")+
  annotate(geom='text',x=1.6,y=1.12,label= expression(paste("3. 1",degree," bile acids",sep="")),size=4,color="#8F1D00")+
  annotate(geom='text',x=3.25,y=0.6,label= expression(paste("4. 2",degree," conjugated conjugated bile acids",sep="")),size=4,color="#056258")+
  annotate(geom='text',x=1.6,y=0.15,label= expression(paste("5. 2",degree," bile acids",sep="")),size=4,color="#6A478F") +
  xlab(NULL) + ylab(NULL) + 
  scale_y_continuous(expand = c(0,0), limits = c(0,2.5)) + 
  theme_void()


## pdf output
pdf("correlation_heatmap.pdf", width = 12, height = 8)
p
vie1 <- viewport(width=0.12, height=0.81, x=0.925, y=0.373)
vie2 <- viewport(width=0.35, height=0.15, x=0.45, y=0.2)
print(p3, vp=vie1)
print(p4, vp=vie2)
dev.off()




