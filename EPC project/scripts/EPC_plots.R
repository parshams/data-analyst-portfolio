# This script performs some statistical analysis of the joined EPC data of Scotland and Manchester
# and produces some plots.

install.packages(c("ggplot2", "corrplot", "reshape2"))
library(ggplot2)
library(corrplot)
library(reshape2)

epc_data <- read.csv("joined_epc_data.csv")



#Identifying outliers in the current energy consumption column 

a_column <- epc_data$ENERGY_CONSUMPTION_CURRENT

Q1 <- quantile(a_column, 0.25, na.rm = TRUE)
Q3 <- quantile(a_column, 0.75, na.rm = TRUE)
IQR <- Q3 - Q1

lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR

outlier_condition <- a_column< lower_bound | a_column > upper_bound
outlier_rows <- epc_data[outlier_condition, ]
rownames(outlier_rows) <- NULL


#removing outliers from the current energy consumption column 

a_column = epc_data$ENERGY_CONSUMPTION_CURRENT
num_sd = 3 #number of standard deviations to remove from the data

mean_value <- mean(a_column, na.rm = TRUE)
sd_value <- sd(a_column, na.rm = TRUE)

upper_threshold <- mean_value + num_sd * sd_value
lower_threshold <- mean_value - num_sd * sd_value

epc_filtered <- epc_data[a_column >= lower_threshold & a_column <= upper_threshold, ]
rownames(epc_filtered) <- NULL




# scatterplot of energy efficiency vs energy consumption
# after the outliers were removed from the energy consumption data

energy_scatter_plot <- ggplot(epc_filtered, aes(x = CURRENT_ENERGY_EFFICIENCY, y = ENERGY_CONSUMPTION_CURRENT)) +
  geom_point(color = "darkred", alpha = 0.6) +
  theme_light() +
  labs(
    title = "Energy Efficiency vs. Energy Consumption",
    x = "Energy Efficiency",
    y = "Energy Consumption"
  ) +
  theme(plot.title = element_text(hjust = 0.5))

print(energy_scatter_plot)
ggsave("energy_scatter_plot.png", plot = energy_scatter_plot)




# Boxpolot of the current energy consumption per property type

energy_by_property_boxplot <- ggplot(epc_filtered, aes(x = PROPERTY_TYPE, y = ENERGY_CONSUMPTION_CURRENT)) +
  theme_light() +
  geom_boxplot(fill = "lightblue", color = "darkblue") +
  scale_y_continuous(breaks = scales::breaks_extended(n = 10)) +
  labs(
    title = "Energy Consumption by Property Type",
    x = "Property Type",
    y = "Energy Consumption"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme(plot.title = element_text(hjust = 0.5))

print(energy_by_property_boxplot)
ggsave("energy_use_by_property_boxplot.png", plot = energy_by_property_boxplot)




# The correlation between select variables

cor_data <- epc_data[, c("ENERGY_CONSUMPTION_CURRENT", "TOTAL_FLOOR_AREA", "ENVIRONMENT_IMPACT_CURRENT", "CURRENT_ENERGY_EFFICIENCY")]

cor_matrix <- cor(cor_data, use = "complete.obs")
cor_matrix_melted <- melt(cor_matrix)

# removing the underscore for the column labels
colnames(cor_matrix) <- gsub("_", " ", colnames(cor_matrix)) 

cor_heatmap <- ggplot(cor_matrix_melted, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
  theme_classic() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),  
    axis.text.y = element_text(size = 8),                         
    axis.title = element_text(size = 10),                         
    plot.margin = margin(10, 10, 10, 10)                         
  ) +
  labs(
    title = "Correlation Heatmap",
    x = "",
    y = ""
  ) +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_x_discrete(labels = colnames(cor_matrix)) +
  scale_y_discrete(labels = colnames(cor_matrix))

print(cor_heatmap)
ggsave("energy_cor_heatmap.png", plot = cor_heatmap)

