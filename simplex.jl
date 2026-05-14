include("utils/prints_handle.jl")
include("utils/operations.jl")
"""
    simplex_iteration(M::Matrix{T}, basicas::Vector{Int}; max=true) where T -> Rational{Int}
"""
function simplex_iteration(M::Matrix{T}, basicas::Vector{Int}; max=true) where T
    
    #verificar se é de minimização o maximização
    if !max # essa comparação so deve ser feita na primeira iteração
        println("Problema de minimização")
        @views M[1,:] = -M[1,:]
    end
    
    # Step 2 - Fazer eliminação de jordan para obter os pivos nas variaves n basicas
    for (i, j) in enumerate(basicas)
       pivot!(M, i+1, j)
    end

    # Step 3 - Verificar se a solução é otima

    if all(M[1, 1:end - 1] .>= 0)
        println()
        println("Solução ótima encontrada!")
        return M[1,end] # retorna o valor ótimo
    else
        # caso contrario econtrar a variavel que deve entrar na base
        new_basic = argmin(M[1,1:(end-1)])


        # e encontrar a variavel que deve sair da base (a que mais limitar seu crescimento)
        ratios = zeros(T, size(M, 1) - 1)
        for i in 2:size(M, 1)
            if M[i, new_basic] > 0
                ratios[i-1] = M[i, end]/M[i, new_basic]
            else
                ratios[i-1] = 0 # se a variavel nao limitar o crescimento da nova basica, entao ela nao pode sair da base
            end
        end
        @show ratios
        if maximum(ratios) <= 0
            println()
            println("Solução ótima encontrada!")
            return M[1,end] # retorna o valor ótimo
        
        else
            leaving_basic = argmin(ratios) + 1 # +1 porque a primeira linha da matriz é a função objetivo

            @show basicas
            @show leaving_basic
            @show basicas[leaving_basic]
            @show new_basic

            println()
            println("Nova variável básica: x$new_basic, Variável que sai da base: x$(basicas[leaving_basic])")
            println()
            println("----------------------------------------")
            println()


            basicas[leaving_basic] = new_basic
            return simplex_iteration(M, basicas; max=true)
        end
    end 


end