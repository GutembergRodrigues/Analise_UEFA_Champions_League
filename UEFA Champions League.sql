-- 1. Qual time tem o maior número de vitórias em finais da UCL? 
SELECT Vencedores, COUNT(*) AS Total_Vitorias
FROM ucl_finals_1955_2023
GROUP BY Vencedores
ORDER BY total_vitorias DESC
LIMIT 1;


-- 2. Liste todos os times que venceram mais de 3 títulos da UCL.
SELECT Vencedores, COUNT(*) AS total_vitorias
FROM ucl_finals_1955_2023
GROUP BY Vencedores
HAVING total_vitorias > 3
ORDER BY total_vitorias DESC;


-- 3. Qual é a média de partidas disputadas pelos times que venceram pelo menos um título da UCL?
SELECT AVG(Partidas) AS media_partidas
FROM ucl_alltime_performance_table
WHERE Titulos > 0;



-- 4. Liste os 5 times com o maior número de participações na UCL (ordenados pelo número de partidas disputadas).
SELECT Time, Partidas
FROM ucl_alltime_performance_table
ORDER BY Partidas DESC
LIMIT 5;



-- 5.Qual país produziu o maior número de times vencedores da UCL?
SELECT País_Vencedor, COUNT(DISTINCT Vencedores) AS total_times_vencedores
FROM ucl_finals_1955_2023
GROUP BY País_Vencedor
ORDER BY total_times_vencedores DESC
LIMIT 1;



-- 6. Quantas finais da UCL foram realizadas na Espanha?
SELECT COUNT(*) AS total_finais_espanha
FROM ucl_finals_1955_2023
WHERE País_Sede = 'Espanha';



-- 7. Qual foi o maior público já registrado em uma final da UCL, e em qual jogo isso ocorreu?
SELECT Vencedores, Perdedor, `Temporada`, `Publico`
FROM ucl_finals_1955_2023
ORDER BY `Publico` DESC
LIMIT 1;



-- 8. Quais times perderam o maior número de finais da UCL?
SELECT Perdedor, COUNT(*) AS total_derrotas
FROM ucl_finals_1955_2023
GROUP BY Perdedor
ORDER BY total_derrotas DESC
LIMIT 5;



-- 9. Liste todos os vencedores da UCL e os placares de jogos que terminaram empatados no tempo regular (ou seja, decididos na prorrogação ou nos pênaltis).
SELECT Vencedores, Perdedor, Temporada, Resultado
FROM ucl_finals_1955_2023
WHERE Resultado LIKE '%a%'
AND SUBSTRING_INDEX(Resultado, ' a ', 1) = SUBSTRING_INDEX(Resultado, ' a ', -1);



-- 10. Qual estádio recebeu a final da UCL mais vezes?
SELECT Estadios, COUNT(*) AS total_finais
FROM ucl_finals_1955_2023
GROUP BY Estadios
ORDER BY total_finais DESC
LIMIT 1;



-- 11. Qual time tem o maior percentual de vitórias na UCL, considerando apenas os times que jogaram mais de 100 partidas?
SELECT Time, percentual_vitorias
FROM (
    SELECT Time, (Vitorias / Partidas) * 100 AS percentual_vitorias
    FROM ucl_alltime_performance_table
    WHERE Partidas > 100
) AS t
ORDER BY percentual_vitorias DESC
LIMIT 1;



-- 12. Qual time tem a melhor diferença de gols nas finais da UCL, calculada como (gols_marcados - gols_sofridos)? (Considerando que o placar está no formato "X a Y")
SELECT Vencedores, MAX(diferenca_gols) AS melhor_diferenca_gols
FROM (
    SELECT Vencedores,
           CAST(SUBSTRING_INDEX(Resultado, ' a ', 1) AS UNSIGNED) - 
           CAST(SUBSTRING_INDEX(Resultado, ' a ', -1) AS UNSIGNED) AS diferenca_gols
    FROM ucl_finals_1955_2023
) AS subquery
GROUP BY Vencedores
ORDER BY melhor_diferenca_gols DESC
LIMIT 1;



-- 13. Qual é o número total de títulos da UCL vencidos por times da Inglaterra?
SELECT SUM(total_titulos) AS total_titulos_inglaterra
FROM (
    SELECT País_Vencedor, COUNT(*) AS total_titulos
    FROM ucl_finals_1955_2023
    GROUP BY País_Vencedor
) AS subquery
WHERE País_Vencedor = 'Inglaterra';



-- 14. Liste todos os times que chegaram à final da UCL, mas nunca venceram o título.
SELECT DISTINCT Perdedor
FROM ucl_finals_1955_2023
WHERE Perdedor NOT IN (
    SELECT Vencedores
    FROM ucl_finals_1955_2023
);



-- 15. Calcule o número total de vitórias, empates e derrotas para cada país e exiba os países em ordem decrescente de vitórias.
WITH CountryPerformance AS (
    SELECT 
        `Países` AS Pais, 
        SUM(Vitorias) AS total_vitorias, 
        SUM(Empates) AS total_empates, 
        SUM(Derrotas) AS total_derrotas
    FROM ucl_alltime_performance_table
    GROUP BY `Países`
)
SELECT 
    Pais, 
    total_vitorias, 
    total_empates, 
    total_derrotas
FROM CountryPerformance
ORDER BY total_vitorias DESC;



-- 16. Classifique todos os times pela média de pontos por partida na UCL (3 pontos por vitória, 1 ponto por empate).
WITH TeamPoints AS (
    SELECT 
        Time, 
        (Vitorias * 3) AS pontos_vitoria,
        (Empates * 1) AS pontos_empate,
        (Vitorias * 3 + Empates * 1) AS total_pontos
    FROM ucl_alltime_performance_table
)
SELECT Time, pontos_vitoria, pontos_empate, total_pontos
FROM TeamPoints
ORDER BY total_pontos DESC
LIMIT 10;


-- 17. Liste todos os times que ja golearam em uma final  
WITH Goleadas AS (
    SELECT 
        Vencedores,
        Perdedor,
        Temporada,
        CAST(SUBSTRING_INDEX(Resultado, ' a ', 1) AS UNSIGNED) - 
        CAST(SUBSTRING_INDEX(Resultado, ' a ', -1) AS UNSIGNED) AS diferenca_gols
    FROM ucl_finals_1955_2023
    WHERE 
        CAST(SUBSTRING_INDEX(Resultado, ' a ', 1) AS UNSIGNED) - 
        CAST(SUBSTRING_INDEX(Resultado, ' a ', -1) AS UNSIGNED) >= 3
)
SELECT Vencedores, Temporada, diferenca_gols
FROM Goleadas
ORDER BY diferenca_gols DESC;



-- 18. Liste os anos em que times do mesmo país venceram e perderam a final (ambos os finalistas do mesmo país).
WITH SameCountryFinals AS (
    SELECT 
        Temporada,
        Vencedores,
        País_Vencedor AS País_Vencedor,
        Perdedor,
        Pais_Perdedor AS Pais_Perdedor
    FROM ucl_finals_1955_2023
    WHERE País_Vencedor = Pais_Perdedor
)
SELECT Temporada, Vencedores, Perdedor, País_Vencedor
FROM SameCountryFinals;


-- 19. Para cada final da UCL, calcule o total acumulado de títulos ganhos pelo vencedor até aquela temporada (contagem cumulativa de títulos).
SELECT 
    Temporada,
    Vencedores,
    COUNT(Vencedores) OVER (PARTITION BY Vencedores ORDER BY Temporada) AS titulos_acumulados
FROM ucl_finals_1955_2023
ORDER BY Temporada;



-- 20. Exiba o time com a maior média de gols marcados em finais da UCL, por década.
WITH FinalGoals AS (
    SELECT 
        Vencedores,
        CAST(SUBSTRING_INDEX(Resultado, ' a ', 1) AS UNSIGNED) AS gols_marcados,
        LEFT(Temporada, 4) AS ano_final
    FROM ucl_finals_1955_2023
), GoalsByDecade AS (
    SELECT 
        Vencedores,
        FLOOR(CAST(ano_final AS UNSIGNED) / 10) * 10 AS decada,
        AVG(gols_marcados) AS media_gols
    FROM FinalGoals
    GROUP BY Vencedores, decada
), RankedGoals AS (
    SELECT 
        Vencedores, 
        decada, 
        media_gols,
        RANK() OVER (PARTITION BY decada ORDER BY media_gols DESC) AS rank_gols
    FROM GoalsByDecade
)
SELECT Vencedores, decada, media_gols
FROM RankedGoals
WHERE rank_gols = 1
ORDER BY decada;


