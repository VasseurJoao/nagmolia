# Inferência em Grafos Aleatórios
## Usando grafos para compreender as relações entre personagens do filme _**Magnólia**_ a partir do roteiro

**João Vasseur e Rafael Silva**

## Instruções

O aplicativo pode ser encontrado no site: https://sjlva.shinyapps.io/magnolia/  

Para executar localmente, abra `magnolia.Rproj`, e clique em `Run App`.

## Requisitos

Os pacotes abaixo são necessários para a execução local:  
```
library(DT)
library(shiny)
library(shinymaterial)
library(zoo)
library(reshape2)
library(tidyverse)
library(networkD3)
```

## Roteiro 

1. O roteiro do filme foi encontrado no site: https://www.dailyscript.com/scripts/magnolia.html
2. Este roteiro foi salvo em `data/magnolia_script.txt`  
3. O roteiro segue um formato de indentação bastante comum entre os roteiros, por exemplo: 

![Trecho do script do filme Magnolia](https://i.imgur.com/M4AeZE5.png)

4. Observe que a indentação do roteiro é bastante informativa, os personagens, falas e cenas seguem uma indentação específica.

## Obtendo os personagens  

Para o obter os personagens, realizamos o algoritmo:
1. Para cada linha:
  + Buscar palavras que começam com a indentação adequada
  + Guardar os personagens e linha do roteiro em que se encontram

2. Para cada cena:
  + Remover personagens repetidos

3. Remover falsos personagens como: (cheers), (aplauses), etc.
4. Verificar grafia dos personagens como: trocar CALUDIA por CLAUDIA
  
## Obtendo as cenas

Para obter as cenas, foram realizados os passos:
1. Para cada linha:
  + Buscar palavras que começam na indentação adequada
  + Verificar se as palvaras começam com os prefixos `INT.`, `EXT`, `INT./EXT.`
  + Guardar as cenas e linha em que se econtram

## Grafos por cena

Para cada cena, temos um grafo. Nos grafos por cena, assumimos que todos os personagens presentes interagem entre si.  

## Grafo geral  

O grafo geral é gerado pelos passos:  
1. Para cada cena:
+ Verifica-se as interações entre os personagens.
2. Para todas as cenas:
+ Se o personagem A interagiu com o personagem B em alguma cena, eles terão conexões no grafo final.
+ Se o personagem A não interagiu com o personagem B em alguma cena, eles não terão conexões no grafo final.

### Grafos gerais  

O app disponibiliza 4 modos de grafos geral disponíveis:
1. Apenas os personagens principais.
2. Os personagens principais, secundários e terciários
3. Os personagens principais, secundários, terciários e quaternários.
4. Todos os personagens do filme.

