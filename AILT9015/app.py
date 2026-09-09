import numpy as np
import pandas as pd
import plotly.express as px
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from shiny import app, ui, render, reactive

# --- 1. DATA GENERATION SCENARIOS ---
def generate_scenario_data(scenario="batch_effect"):
    np.random.seed(42)
    n_samples = 100
    n_genes = 50
    
    # Create base metadata
    df = pd.DataFrame({
        "SampleID": [f"S{i+1}" for i in range(n_samples)],
        "Condition": ["Healthy"] * 50 + ["Disease"] * 50,
        "Batch": ["Batch A", "Batch B"] * 50
    })
    
    # Generate baseline expression
    expr_matrix = np.random.normal(loc=10, scale=2, size=(n_samples, n_genes))
    
    if scenario == "normal":
        # Biological Effect
        expr_matrix[50:, 0:5] += 3
        # Minimal batch effect
        batch_b_idx = df[df["Batch"] == "Batch B"].index
        expr_matrix[batch_b_idx, 5:10] += 0.5
        
    elif scenario == "batch_effect":
        # Small biological effect
        expr_matrix[50:, 0:5] += 2
        # Large Batch Effect dominating variance
        batch_b_idx = df[df["Batch"] == "Batch B"].index
        expr_matrix[batch_b_idx, 5:25] += 8
        
    elif scenario == "selection_bias":
        # Confounding condition with batch
        batches = []
        for cond in df["Condition"]:
            if cond == "Disease":
                batches.append(np.random.choice(["Batch A", "Batch B"], p=[0.2, 0.8]))
            else:
                batches.append(np.random.choice(["Batch A", "Batch B"], p=[0.8, 0.2]))
        df["Batch"] = batches
        
        # Moderate biological effect
        expr_matrix[df["Condition"] == "Disease", 0:5] += 2.5
        # Moderate batch effect
        batch_b_idx = df[df["Batch"] == "Batch B"].index
        expr_matrix[batch_b_idx, 5:15] += 3
        
    gene_cols = [f"Gene_{i+1}" for i in range(n_genes)]
    expr_df = pd.DataFrame(expr_matrix, columns=gene_cols)
    return pd.concat([df, expr_df], axis=1)

# --- 2. USER INTERFACE ---
app_ui = ui.page_sidebar(
    ui.sidebar(
        ui.input_radio_buttons(
            "scenario", "Select Scenario:",
            {
                "normal": "Normal (Clean Data)",
                "batch_effect": "Batch Effect (Large Technical Variation)",
                "selection_bias": "Selection Bias (Confounded Condition & Batch)"
            },
            selected="batch_effect"
        ),
        ui.br(),
        ui.input_radio_buttons(
            "data_source", "Data Source:",
            {"builtin": "Built-in Scenario", "upload": "Upload Custom Dataset"},
            selected="builtin"
        ),
        # Conditional UI elements
        ui.panel_conditional(
            "input.data_source == 'upload'",
            ui.input_file("user_file", "Upload Custom Dataset (CSV)", accept=[".csv"]),
            ui.input_select("cond_col", "Select Biological Condition Column:", choices=[]),
            ui.input_select("batch_col", "Select Processing Batch Column:", choices=[]),
            ui.input_selectize("feature_cols", "Select PCA feature columns:", choices=[], multiple=True)
        )
    ),
    ui.card(
        ui.card_header("PCA Plot Matrix"),
        render.ui("plot_wrapper") # Dynamic plot placeholder
    ),
    title="PCA & Batch Effect Explorer"
)

# --- 3. SERVER LOGIC ---
def server(input, output, session):
    
    # Reactive dataset loading
    @reactive.calc
    def dataset():
        if input.data_source() == "upload" and input.user_file() is not None:
            file_info = input.user_file()[0]
            return pd.read_csv(file_info["datapath"])
        return generate_scenario_data(input.scenario())

    # Dynamically update dropdown inputs based on the data loaded
    @reactive.effect
    def _update_inputs():
        df = dataset()
        cat_cols = list(df.select_dtypes(include=["object", "category"]).columns)
        numeric_cols = list(df.select_dtypes(include=["number"]).columns)
        
        cond_sel = "Condition" if "Condition" in cat_cols else (cat_cols[0] if cat_cols else None)
        batch_choices = ["None"] + cat_cols
        batch_sel = "Batch" if "Batch" in cat_cols else "None"
        
        ui.update_select("cond_col", choices=cat_cols, selected=cond_sel)
        ui.update_select("batch_col", choices=batch_choices, selected=batch_sel)
        ui.update_selectize("feature_cols", choices=numeric_cols, selected=numeric_cols)

    # Reactive PCA Execution
    @reactive.calc
    def pca_result():
        df = dataset()
        numeric_cols = list(df.select_dtypes(include=["number"]).columns)
        selected_features = input.feature_cols()
        
        if not selected_features:
            selected_features = numeric_cols
            
        features = [f for f in selected_features if f in numeric_cols]
        num_data = df[features].copy()
        
        # Remove zero-variance columns
        num_data = num_data.loc[:, num_data.var() != 0]
        
        # Scale and run PCA
        scaled_data = StandardScaler().fit_transform(num_data)
        pca = PCA(n_components=2)
        pca_coords = pca.fit_transform(scaled_data)
        
        df["PC1"] = pca_coords[:, 0]
        df["PC2"] = pca_coords[:, 1]
        
        var_explained = np.round(pca.explained_variance_ratio_ * 100, 1)
        return df, var_explained

    # Render interactive plot using Plotly
    @output
    @render.ui
    def plot_wrapper():
        df, var_exp = pca_result()
        cond = input.cond_col()
        batch = input.batch_col()
        
        if not cond:
            return ui.p("Please ensure a valid condition column is selected.")
            
        # Plot styling parameters
        kwargs = {
            "x": "PC1", "y": "PC2",
            "color": cond,
            "labels": {
                "PC1": f"PC1 ({var_exp[0]}% Variance)",
                "PC2": f"PC2 ({var_exp[1]}% Variance)"
            },
            "template": "plotly_white",
            "hover_data": ["SampleID"] if "SampleID" in df.columns else None
        }
        
        if batch and batch != "None":
            kwargs["symbol"] = batch
            
        fig = px.scatter(df, **kwargs)
        fig.update_traces(marker=dict(size=12, opacity=0.85))
        return fig

app = App(app_ui, server)