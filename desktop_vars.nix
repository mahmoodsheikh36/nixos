{ pkgs, ... }: {
  desktop_python = (pkgs.python3.withPackages (ps: with ps; [
    matplotlib flask requests panflute numpy jupyter jupyter-core pytorch pandas sympy scipy
    scikit-learn torchvision beautifulsoup4 seaborn pillow dash mysql-connector
    rich pyspark networkx dpkt python-lsp-server #opencv
    graphviz flask-sqlalchemy flask-cors ariadne graphene nltk
    transformers diffusers spacy
  ]));
  desktop_julia = (pkgs.julia.withPackages.override({ precompile = false; })([
    "TruthTables" "LinearSolve"
    "Plots" "Graphs" "CSV" "NetworkLayout" "SGtSNEpi" "Karnak" "DataFrames"
    "TikzPictures" "Gadfly" "Makie" "Turing" "RecipesPipeline"
    "LightGraphs" "JET" "HTTP" "LoopVectorization" "OhMyREPL" "MLJ"
    "Luxor" "ReinforcementLearningBase" "Images" "Flux" "DataStructures" "RecipesBase"
    "Latexify" "Distributions" "StatsPlots" "Gen" "Zygote" "UnicodePlots" "StaticArrays"
    "Weave" "BrainFlow" "Genie" "WaterLily" "LanguageServer"
    "Symbolics" "SymbolicUtils" "ForwardDiff" "Metatheory" "TermInterface" "SymbolicRegression"
    # "Transformers" "Optimization" "Knet" "ModelingToolkit"
    # "CUDA" "Javis" "GalacticOptim" "Dagger" "Interact"
  ]));
}