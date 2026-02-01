# Proyecto-Optimizacion-Inversiones
# Proyecto Optimización de Inversiones – MVP Portfolio Mensual

##  Objetivo del Proyecto

Este proyecto desarrolla un Producto Mínimo Viable (MVP) basado en un modelo financiero cuantitativo, cuyo objetivo es

- Construir un portafolio óptimo de inversión  
- Maximizar el retorno esperado para un nivel dado de riesgo  
- Comparar el desempeño contra un benchmark real (SPY – S&P500)  
- Entregar una solución aplicable a un negocio financiero  

---

##  Problema de Negocio que Resuelve

En la industria financiera, inversionistas y asesores enfrentan el desafío de:

- Elegir activos adecuados dentro de miles de opciones
- Diversificar correctamente
- Optimizar riesgo vs retorno
- Medir si la cartera realmente supera al mercado

Un modelo matemático por sí solo no genera valor, pero su utilización como herramienta sí.

Este MVP permite entregar:

- Pesos óptimos listos para implementar  
- Métricas claras de evaluación  
- Comparación con índice benchmark  
- Entregables exportables para clientes o negocio

---

##  Solución Propuesta (Entrega de Valor)

Este proyecto entrega una solución práctica:

 Un asesor financiero o cliente puede correr el script y obtener:

- Distribución óptima del portafolio
- Retorno y volatilidad mensual esperada
- Comparación contra SPY
- CSV exportables listos para reporte

Esto permite:

° Automatizar recomendaciones de inversión  
° Reducir decisiones subjetivas  
° Mejorar eficiencia en gestión de carteras  
° Crear un producto escalable tipo robo-advisor  

---

##  Metodología

Se aplica un flujo tipo MLOps financiero:

1. *Collect Data* 
   Datos descargados desde Yahoo Finance (tidyquant)

2. *Clean Data* 
   Cálculo de retornos mensuales y limpieza

3. *Train Model* 
   Optimización media-varianza (Markowitz)

4. *Solution Delivery*  
   Pesos óptimos exportados como entregable

---

##  Modelo Matemático Utilizado

El modelo corresponde a una optimización clásica:

- Maximización del retorno esperado
- Minimización del riesgo (varianza)
- Restricción: suma de pesos = 1

Se usa el paquete:

- `PortfolioAnalytics`

---

## 📁 Estructura del Repositorio

