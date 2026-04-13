# Projeto Bootcamp DIO - Power Query com Copilot no Excel

## Visão geral

Projeto desenvolvido no contexto do bootcamp da DIO com foco em análise de dados utilizando Excel.

O objetivo foi construir um dashboard para acompanhamento de desempenho de assinaturas, considerando volume e receita ao longo do tempo.

---

## Base de dados

A base contém informações de assinantes, incluindo:

* Subscriber ID
* Data de início (Start Date)
* Tipo de plano
* Valores (Monthly, Coupon e Total Value)

Os dados foram tratados e padronizados antes da análise.

---

## Tratamento de dados

O tratamento foi realizado utilizando Power Query, incluindo:

* Ajuste de tipos de dados (principalmente datas e valores)
* Limpeza de inconsistências (valores nulos e caracteres inválidos)
* Preparação da base para análise em Pivot Table

---

## Modelagem e análise

A análise foi construída com Pivot Tables, utilizando agregações e agrupamentos por período (mês/ano).

### KPIs principais:

* Quantidade de assinaturas (COUNT de Subscriber ID)
* Receita total (SUM de Total Value)
* Evolução mensal (análise temporal)

---

## Dashboard

O dashboard foi desenvolvido na aba **Dashboard**, com foco em:

* Visualização da evolução mensal
* Comparação entre volume de assinaturas e receita
* Uso de gráficos combinados (coluna + linha)

---

## Como reproduzir

1. Abrir o arquivo `Desafio_Dashboard.xlsx`
2. Atualizar os dados: **Data → Refresh All**
3. Navegar até a aba **Dashboard**
4. Utilizar os filtros e segmentações disponíveis

---

## Tecnologias utilizadas

* Microsoft Excel
* Power Query
* Pivot Tables

---

## Objetivo do projeto

Consolidar conceitos de:

* Tratamento de dados
* Criação de KPIs
* Análise temporal
* Construção de dashboards


👨‍💻 Desenvolvido por **Paulo** durante o Bootcamp DIO  
📅 Abril/2026
