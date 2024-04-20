let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (ps: with ps; [
      matplotlib flask requests panflute numpy jupyter jupyter-core pytorch pandas sympy scipy
      scikit-learn torchvision scrapy beautifulsoup4 seaborn pillow dash mysql-connector
      rich pyspark networkx dpkt python-lsp-server #opencv
      graphviz flask-sqlalchemy flask-cors ariadne graphene nltk
    ]))
  ];
}