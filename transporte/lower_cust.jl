import LinearAlgebra

export lower_cust, sort_base, create_constraints_matrix

# Recebe a matriz dos custos e os limites de oferta/demanda e retorna a solução inicial básica compativel usando o método do custo mínimo.
function lower_cust(C::Matrix{T}, oferta::Vector{T}, demanda::Vector{T}) where T
    # Checar dimensionalidade
    if size(C, 1) != length(oferta) || size(C, 2) != length(demanda)
        error("Dimensionalidade da matriz de custos não é compatível com os vetores de oferta e demanda.")
    end

    rank = size(C, 1)+size(C, 2) -1

    # Criar a matrix da base inicial
    base = zeros(T, rank)

    for i in 1:rank

        # Step 1 - Encontrar o menor custo na matrix
        index = argmin(C)
        println("menor custo:", C[index])

        # Step 2 - Alocar o máximo possível
        allocation = min(oferta[index[1]], demanda[index[2]])

        println()

        println("Alocação: ", allocation)

        # Step 3 - Atualizar oferta e demanda
        oferta[index[1]] -= allocation
        demanda[index[2]] -= allocation

        println()

        println("Oferta restante: ", oferta)
        println("Demanda restante: ", demanda)

        println()

        # Step 4 - Armazenar a alocação na base
        # A posição da base é dada por (i-1)*size(C, 2) + j, onde i e j são os índices da matriz de custos
        base[i] = (index[1]-1)*size(C, 2) + index[2]

        # Step 5 - Marcar o custo como infinito para não ser escolhido novamente
        C[index] = typemax(T)
    end
    
    return base

end

function sort_base(A::Matrix{Rational}, base::Set{Int}, length_demanda::Int)
    
    # as colunas multiplas de length_demanda sempre estao pivotadas
    sorted_base = zeros(Int, length(base))

    for var in base
        # se o elemento for multiplo de length_demanda
        if var%length_demanda == 0
            pop!(base, var) # remove da base
            sorted_base[Int(var/length_demanda)] = Int(var) # add na posicao respectiva
        end
    end

    println("Base ordenada parcialmente: ", sorted_base)

    # add as ultimas variaveis nos espaços restantes
    for (i, var) in enumerate(sorted_base)
        if var == 0
            for j in base # descobrir a proxima variavel que nao é zero na linha i
                if A[i, j] != 0 
                    # nao podemos simplesmente colocar o primerio que encaixar
                    # é preciso verificar se nao tem outro que o unico lugar dele seria aí
                    pop!(base, j) 
                    sorted_base[i] = j
                end
            end
        end
    end

    println("Base ordenada: ", sorted_base)

    if any(sorted_base .== 0)
        println("Erro: Base não foi ordenada corretamente.")
        println("Tentando denovo")

        for (i, var) in enumerate(sorted_base)
            println("quero ver quantas vezes essa variavel que sobrou poderia ter entrado")
        end

    end

    return sorted_base

end

# criando a mtrix de restrições e tirando a ultima linha para o rank ser igual a m+n - 1 
# talvez fique mais claro criar com vcat e hcat
# function create_constraints_matrix(oferta, demanda)
#     A = zeros(Rational, oferta + demanda - 1, oferta*demanda)

#     for i in 1:oferta
#         for j in 1:demanda
#             A[i,j+((i-1)*(oferta + 1))] = 1
#         end
#     end

#     for i in oferta+1:oferta+demanda-1
#         for j in 1:demanda:size(A, 2)
#             println(j)
#             A[i,j + i - oferta - 1] = 1
#         end
#     end


#     return A
# end

function create_constraints_matrix(length_oferta::Int, length_demanda::Int)
    A = ones(Int, 1, length_demanda)
    A = hcat(A, zeros(Int, 1, (length_oferta - 1)*length_demanda))

    for i in 2:length_oferta 
        line = zeros(Int, 1, length_demanda)
        for j in 2:length_oferta
            i == j ? line = hcat(line, ones(Int, 1, length_demanda)) : line = hcat(line, zeros(Int, 1, length_demanda))
        end
        A = vcat(A, line)
    end

    last_block = I(length_demanda)
    for _ in 2:length_oferta
        last_block = hcat(last_block, I(length_demanda))
    end
    A = vcat(A, last_block)

    A = A[1:end-1, :]

    return Rational{Int}.(A)
end