include("utils/prints_handle.jl")
include("utils/operations.jl")

function simplex_iteration(M::Matrix{T}, basicas::Vector{Int}; max=true) where T
    # Step 1 - Fazer eliminação de jordan para obter os pivos nas variaves n basicas
    for (i, j) in enumerate(basicas)
       pivot!(M, i+1, j)
    end
    
    # Step - Verificar se a solução é otima
    if max
        if all(M[1, :] .>= 0)
            println()
            println("Solução ótima encontrada!")
            return M
        else
            # caso contrario econtrar a variavel que deve entrar na base
            new_basic = argmin(M[1,1:(end-1)])

            # e encontrar a variavel que deve sair da base (a que mais limitar seu crescimento)
            ratios = M[2:end, new_basic] ./ M[2:end, end]
            @show ratios
            if maximum(ratios) <= 0
                println()
                println("Solução ótima encontrada!")
                return M
            
            else
                leaving_basic = argmin(ratios)
                println()
                println("Nova variável básica: x$new_basic, Variável que sai da base: x$(basicas[leaving_basic])")
                println()
                println("----------------------------------------")
                println()
                basicas[leaving_basic] = new_basic
                return simplex_iteration(M, basicas; max)
            end
        end
    end
end