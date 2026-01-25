# =========================
# TRABAJO 1 - MVP (MENSUAL)
# Optimización de portafolio + Evaluación vs Benchmark + Export + Diagrama
# =========================

# --- FASE 0: LIBRERÍAS ---
library(tidyquant)
library(tidyverse)
library(PortfolioAnalytics)
library(PerformanceAnalytics)
library(ROI)
library(ROI.plugin.quadprog)
library(DiagrammeR)
library(janitor)

# --- FASE 1: COLLECT DATA ---
tickers   <- c("AAPL", "MSFT", "AMZN", "JPM", "JNJ", "XOM", "PG", "V", "KO", "TSLA")
benchmark <- "SPY"  # ETF S&P500 como benchmark

precios <- tq_get(c(tickers, benchmark),
                  from = "2020-01-01", to = "2025-01-01",
                  get = "stock.prices")

# --- FASE 2: UNDERSTAND AND CLEAN DATA (RETORNOS MENSUALES) ---
retornos_tbl <- precios %>%
  group_by(symbol) %>%
  tq_transmute(
    select = adjusted,
    mutate_fun = periodReturn,
    period = "monthly",
    col_rename = "retorno"
  )

retornos_wide <- retornos_tbl %>%
  pivot_wider(names_from = symbol, values_from = retorno) %>%
  arrange(date) %>%
  na.omit()

# Separar benchmark y activos
ret_bench_tbl   <- retornos_wide %>% select(date, all_of(benchmark))
ret_activos_tbl <- retornos_wide %>% select(date, all_of(tickers))

# Matrices para PortfolioAnalytics / PerformanceAnalytics
R_activos <- ret_activos_tbl %>%
  column_to_rownames("date") %>%
  as.matrix()

R_bench <- ret_bench_tbl %>%
  column_to_rownames("date") %>%
  as.matrix()

# --- FASE 3: TRAIN MODEL (OPTIMIZACIÓN MEDIA-VARIANZA) ---
port_spec <- portfolio.spec(assets = colnames(R_activos))
port_spec <- add.constraint(portfolio = port_spec, type = "full_investment")
port_spec <- add.constraint(portfolio = port_spec, type = "long_only")
port_spec <- add.objective(portfolio = port_spec, type = "return", name = "mean")
port_spec <- add.objective(portfolio = port_spec, type = "risk", name = "StdDev")

opt_portfolio <- optimize.portfolio(
  R = R_activos,
  portfolio = port_spec,
  optimize_method = "ROI"
)

pesos <- extractWeights(opt_portfolio)

# --- FASE 3B: EVALUATE MODEL (MÉTRICAS EX-POST) ---
# Retorno del portafolio optimizado (mensual)
ret_port <- Return.portfolio(R = R_activos, weights = pesos, rebalance_on = NA)

# Escalamiento anual (porque los retornos son mensuales)
scale_annual <- 12

ret_prom_mensual_port <- mean(ret_port)
vol_mensual_port      <- StdDev(ret_port)
ret_prom_anual_port   <- (1 + ret_prom_mensual_port) ^ scale_annual - 1
vol_anual_port        <- vol_mensual_port * sqrt(scale_annual)

ret_prom_mensual_bench <- mean(R_bench)
vol_mensual_bench      <- StdDev(R_bench)
ret_prom_anual_bench   <- (1 + ret_prom_mensual_bench) ^ scale_annual - 1
vol_anual_bench        <- vol_mensual_bench * sqrt(scale_annual)

sh_port  <- as.numeric(SharpeRatio.annualized(ret_port, scale = scale_annual))
sh_bench <- as.numeric(SharpeRatio.annualized(R_bench,  scale = scale_annual))

dd_port  <- as.numeric(maxDrawdown(ret_port))
dd_bench <- as.numeric(maxDrawdown(R_bench))

comparacion <- tibble(
  metrica = c("Retorno promedio mensual",
              "Volatilidad mensual",
              "Retorno promedio anual (aprox)",
              "Volatilidad anual (aprox)",
              "Sharpe anualizado",
              "Max Drawdown"),
  portafolio = c(ret_prom_mensual_port,
                 vol_mensual_port,
                 ret_prom_anual_port,
                 vol_anual_port,
                 sh_port,
                 dd_port),
  benchmark = c(ret_prom_mensual_bench,
                vol_mensual_bench,
                ret_prom_anual_bench,
                vol_anual_bench,
                sh_bench,
                dd_bench)
)

print(comparacion)

# --- FASE 4: VISUALIZACIÓN (SOLUCIÓN DE NEGOCIO) ---
# Pesos óptimos
PortfolioAnalytics::chart.Weights(opt_portfolio, main = "Distribución Óptima (Mensual) 2020-2025")

# Crecimiento acumulado (Portafolio vs Benchmark)
chart.CumReturns(
  cbind(ret_port, R_bench),
  legend.loc = "topleft",
  main = "Crecimiento acumulado: Portafolio vs SPY"
)

# --- FASE 4B: EXPORT (SALIDAS PARA REPORTING) ---
pesos_df <- tibble(activo = names(pesos), peso = as.numeric(pesos)) %>%
  arrange(desc(peso))

write_csv(pesos_df, "pesos_optimos.csv")
write_csv(comparacion, "metricas_portafolio_vs_benchmark.csv")

# --- FASE 5: DOCUMENTACIÓN (DIAGRAMA) ---
DiagrammeR::grViz("digraph {
  graph [layout = dot, rankdir = LR]
  node [shape = rectangle, style = filled, fillcolor = '#D5F5E3']

  A [label = 'Collect Data\\n(Yahoo Finance / tidyquant)']
  B [label = 'Clean Data\\n(Returns mensuales, NA omit)']
  C [label = 'Train Model\\n(Optimización media-varianza)']
  D [label = 'Evaluate\\n(Sharpe, Drawdown, vs SPY)']
  E [label = 'Deploy\\n(CSV + Dashboard)']
  F [label = 'Monitor\\n(Rebalance mensual + alertas)']

  A -> B -> C -> D -> E -> F
}")

