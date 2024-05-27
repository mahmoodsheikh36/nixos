let
    pkgs2 = import (builtins.fetchGit {
         # Descriptive name to make the store path easier to identify
         name = "my-old-revision";
         url = "https://github.com/NixOS/nixpkgs/";
         ref = "refs/heads/nixpkgs-unstable";
         rev = "336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3";
     }) {};

     my_julia = pkgs2.julia;
in
{ pkgs, ... }: {
  desktop_python = (pkgs.python3.withPackages (ps: with ps; [
    matplotlib flask requests panflute numpy jupyter jupyter-core pytorch pandas sympy scipy
    scikit-learn torchvision beautifulsoup4 seaborn pillow dash mysql-connector
    rich pyspark networkx dpkt python-lsp-server #opencv
    graphviz flask-sqlalchemy flask-cors ariadne graphene nltk
    transformers diffusers spacy
  ]));
  desktop_julia = (my_julia.withPackages.override({ precompile = true; })([
    # "TruthTables" "LinearSolve"
    # "LightGraphs" "HTTP" "OhMyREPL" "MLJ"
    # "Luxor" "ReinforcementLearningBase" "DataStructures" "RecipesBase"
    # "Latexify" "Distributions" "Gen" "UnicodePlots" "StaticArrays"
    # "Genie" "WaterLily"
    # "Symbolics" "SymbolicUtils" "ForwardDiff" "Metatheory" "TermInterface" "SymbolicRegression"
    # "Transformers" "Optimization" "Knet" "ModelingToolkit" "StatsPlots" "GLMakie" "Zygote"
    # "Flux" "JET" "LoopVectorization" "Weave" "BrainFlow"
    # "CUDA" "Javis" "GalacticOptim" "Dagger" "Interact"
    # "Gadfly" "Turing" "RecipesPipeline"

    "LanguageServer"
    "Images"

    # math
    "Graphs"

    # data processing
    "JSON" "DataFrames" "CSV"

    # graphics
    "Makie" "SGtSNEpi" "Karnak"
    "Plots" "TikzPictures" "NetworkLayout"
    "GraphRecipes"
  ]));
}