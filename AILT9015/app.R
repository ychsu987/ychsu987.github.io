library(shiny)
library(ggplot2)
library(dplyr)
library(tibble)
library(bslib) 

# ==========================================
# 1. SETUP & DATA GENERATION FUNCTIONS
# ==========================================
generate_scenario_data <- function(scenario = "batch_effect") {
  set.seed(42)
  n_samples <- 100
  n_genes <- 50
  default_data <- tibble(
    SampleID = paste0("S", 1:n_samples),
    Condition = rep(c("Healthy", "Disease"), each = n_samples/2),
    Batch = rep(c("Batch A", "Batch B"), times = n_samples/2)
  )
  expr_matrix <- matrix(rnorm(n_samples * n_genes, mean = 10, sd = 2), nrow = n_samples)
  
  if (scenario == "normal") {
    expr_matrix[1:(n_samples/2), 1:5] <- expr_matrix[1:(n_samples/2), 1:5] + 3
    batch_b_indices <- which(default_data$Batch == "Batch B")
    expr_matrix[batch_b_indices, 6:10] <- expr_matrix[batch_b_indices, 6:10] + 0.5
  } else if (scenario == "batch_effect") {
    expr_matrix[1:(n_samples/2), 1:5] <- expr_matrix[1:(n_samples/2), 1:5] + 2
    batch_b_indices <- which(default_data$Batch == "Batch B")
    expr_matrix[batch_b_indices, 6:25] <- expr_matrix[batch_b_indices, 6:25] + 8
  } else if (scenario == "selection_bias") {
    disease_indices <- which(default_data$Condition == "Disease")
    healthy_indices <- which(default_data$Condition == "Healthy")
    batch_assignment <- character(n_samples)
    batch_assignment[disease_indices] <- sample(c("Batch A", "Batch B"), length(disease_indices), replace = TRUE, prob = c(0.2, 0.8))
    batch_assignment[healthy_indices] <- sample(c("Batch A", "Batch B"), length(healthy_indices), replace = TRUE, prob = c(0.8, 0.2))
    default_data$Batch <- batch_assignment
    expr_matrix[default_data$Condition == "Disease", 1:5] <- expr_matrix[default_data$Condition == "Disease", 1:5] + 2.5
    batch_b_indices <- which(default_data$Batch == "Batch B")
    expr_matrix[batch_b_indices, 6:15] <- expr_matrix[batch_b_indices, 6:15] + 3
  }
  expr_df <- as.data.frame(expr_matrix)
  colnames(expr_df) <- paste0("Gene_", 1:n_genes)
  bind_cols(default_data, expr_df)
}

default_df <- generate_scenario_data("batch_effect")

# ==========================================
# 2. DEFINE THE UI
# ==========================================
ui <- page_sidebar(
  title = "PCA & Batch Effect Explorer",
  sidebar = sidebar(
    radioButtons("scenario", "Select Scenario:", 
                 choices = list("Normal (Clean Data)" = "normal",
                               "Batch Effect (Large Technical Variation)" = "batch_effect",
                               "Selection Bias (Confounded Condition & Batch)" = "selection_bias"),
                 selected = "batch_effect"),
    br(),
    radioButtons("data_source", "Data Source:", 
                 choices = list("Built-in Scenario" = "builtin",
                               "Upload Custom Dataset" = "upload"),
                 selected = "builtin"),
    conditionalPanel(
      condition = "input.data_source == 'upload'",
      fileInput("user_file", "Upload Custom Dataset (CSV)", 
                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      helpText("Upload a CSV where rows are samples and columns are features (genes/proteins). Ensure you have categorical columns for Condition and Batch."),
      selectInput("cond_col", "Select Biological Condition Column:", choices = NULL),
      selectInput("batch_col", "Select Processing Batch Column:", choices = NULL),
      selectizeInput("feature_cols", "Select PCA feature columns:", choices = NULL, multiple = TRUE)
    )
  ),
  card(
    card_header("PCA Plot"),
    plotOutput("pca_batch_plot", height = "600px")
  )
)

# ==========================================
# 3. DEFINE THE SERVER LOGIC
# ==========================================
server <- function(input, output, session) {
  
  # Reactive expression to load data
  dataset <- reactive({
    if (input$data_source == "upload" && !is.null(input$user_file)) {
      return(read.csv(input$user_file$datapath, stringsAsFactors = TRUE))
    } else {
      return(generate_scenario_data(input$scenario))
    }
  })
  
  # Update UI dropdown choices dynamically based on loaded dataset [cite: 10, 11]
  observeEvent(dataset(), {
    df <- dataset() [cite: 10]
    cat_cols <- names(df)[sapply(df, function(x) is.character(x) | is.factor(x))] [cite: 10]
    numeric_cols <- names(df)[sapply(df, is.numeric)] [cite: 10]
    
    updateSelectInput(session, "cond_col", choices = cat_cols, 
                      selected = ifelse("Condition" %in= cat_cols, "Condition", ifelse(length(cat_cols) > 0, cat_cols[1], NULL))) [cite: 10]
    batch_choices <- c("None" = "None", setNames(cat_cols, cat_cols)) [cite: 11]
    updateSelectInput(session, "batch_col", choices = batch_choices, 
                      selected = ifelse("Batch" %in% cat_cols, "Batch", "None")) [cite: 11]
    updateSelectInput(session, "feature_cols", choices = numeric_cols, selected = numeric_cols) [cite: 11]
  })
  
  # Perform PCA [cite: 12]
  pca_result <- reactive({
    df <- dataset() [cite: 12]
    numeric_cols <- names(df)[sapply(df, is.numeric)] [cite: 12]
    selected_features <- input$feature_cols [cite: 12]
    if (is.null(selected_features) || length(selected_features) == 0) { [cite: 12]
      selected_features <- numeric_cols [cite: 12]
    }
    num_data <- df %>% select(all_of(intersect(selected_features, numeric_cols))) [cite: 12]
    num_data <- num_data[, apply(num_data, 2, var) != 0] # Remove zero variance columns [cite: 12]
    
    pca <- prcomp(num_data, center = TRUE, scale. = TRUE) [cite: 12]
    pca_data <- bind_cols(df, as_tibble(pca$x[, 1:2])) [cite: 12]
    var_explained <- round(pca$sdev^2 / sum(pca$sdev^2) * 100, 1) [cite: 12]
    
    list(data = pca_data, var = var_explained) [cite: 12]
  })
  
  # Render Plot Output [cite: 14, 16, 17]
  output$pca_batch_plot <- renderPlot({
    req(input$batch_col) [cite: 14]
    res <- pca_result() [cite: 14]
    
    if (input$batch_col == "None") { [cite: 14]
      ggplot(res$data, aes(x = PC1, y = PC2, color = .data[[input$cond_col]])) + [cite: 14]
        geom_point(size = 5, alpha = 0.85) + [cite: 14]
        theme_minimal(base_size = 16) + [cite: 14]
        labs( [cite: 14]
          x = paste0("PC1 (", res$var[1], "% Variance)"), [cite: 14]
          y = paste0("PC2 (", res$var[2], "% Variance)"), [cite: 14]
          color = "Biological Condition" [cite: 14]
        ) + [cite: 14]
        theme( [cite: 14]
          legend.position = "right", [cite: 15]
          panel.grid.major = element_line(color = "grey80"), [cite: 15]
          panel.grid.minor = element_line(color = "grey90") [cite: 15]
        ) [cite: 14]
    } else { [cite: 15]
      ggplot(res$data, aes(x = PC1, y = PC2,  [cite: 16]
                          color = .data[[input$cond_col]],  [cite: 16]
                          shape = .data[[input$batch_col]])) + [cite: 16]
        geom_point(size = 5, alpha = 0.85) + [cite: 16]
        theme_minimal(base_size = 16) + [cite: 16]
        labs( [cite: 16]
          x = paste0("PC1 (", res$var[1], "% Variance)"), [cite: 16]
          y = paste0("PC2 (", res$var[2], "% Variance)"), [cite: 16]
          color = "Biological Condition", [cite: 16]
          shape = "Processing Batch" [cite: 17]
        ) + [cite: 16]
        theme( [cite: 17]
          legend.position = "right", [cite: 17]
          legend.box = "vertical", [cite: 17]
          panel.grid.major = element_line(color = "grey80"), [cite: 17]
          panel.grid.minor = element_line(color = "grey90") [cite: 17]
        ) [cite: 16]
    }
  })
}

# ==========================================
# 4. RUN THE APPLICATION
# ==========================================
shinyApp(ui = ui, server = server)