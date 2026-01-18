# --- FASE 0: CARGA DE LIBRERÍAS ---
library(tidyquant)
library(tidyverse)
library(PortfolioAnalytics)
library(PerformanceAnalytics)
library(ROI)
library(ROI.plugin.quadprog)
library(DiagrammeR)

# --- FASE 1: COLLECT DATA (Punto 55 del PDF) ---
tickers <- c("AAPL", "MSFT", "AMZN", "JPM", "JNJ", "XOM", "PG", "V", "KO", "TSLA")
precios <- tq_get(tickers, from = "2020-01-01", to = "2025-01-01", get = "stock.prices")

# --- FASE 2: UNDERSTAND AND CLEAN DATA (Puntos 56-57 del PDF) ---
retornos <- precios %>%
  group_by(symbol) %>%
  tq_transmute(select = adjusted, mutate_fun = periodReturn, period = "monthly", col_rename = "retorno") %>%
  pivot_wider(names_from = symbol, values_from = retorno) %>%
  column_to_rownames(var = "date") %>%
  na.omit()

# --- FASE 3: TRAIN AND EVALUATE MODEL (MVP - Punto 58 del PDF) ---
port_spec <- portfolio.spec(assets = colnames(retornos))
port_spec <- add.constraint(portfolio = port_spec, type = "full_investment")
port_spec <- add.constraint(portfolio = port_spec, type = "long_only")
port_spec <- add.objective(portfolio = port_spec, type = "return", name = "mean")
port_spec <- add.objective(portfolio = port_spec, type = "risk", name = "StdDev")

opt_portfolio <- optimize.portfolio(R = retornos, portfolio = port_spec, optimize_method = "ROI")

# --- FASE 4: VISUALIZACIÓN (SOLUCIÓN DE NEGOCIO) ---
# Aparecerá en la pestaña 'Plots'
PortfolioAnalytics::chart.Weights(opt_portfolio, main = "Distribución Óptima 2020-2025")

# --- FASE 5: DOCUMENTACIÓN (DIAGRAMA - Punto 4 del PDF) ---
# Aparecerá en la pestaña 'Viewer'
DiagrammeR::grViz("digraph {
  graph [layout = dot, rankdir = LR]
  node [shape = rectangle, style = filled, fillcolor = '#D5F5E3']
  
  A [label = 'Collect Data\n(Yahoo Finance)']
  B [label = 'Clean Data\n(Returns & Tidy)']
  C [label = 'Train Model\n(Optimization)']
  D [label = 'Solution\n(Optimal Weights)']
  
  A -> B -> C -> D
}")




