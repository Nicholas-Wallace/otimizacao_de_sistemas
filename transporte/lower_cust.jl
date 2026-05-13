
# Recebe a matriz dos custos e os limites de oferta/demanda e retorna a solução inicial básica compativel usando o método do custo mínimo.
function lower_cust(C::Matrix{T}, oferta::Vector{T}, demanda::Vector{T}) where T
    # Checar dimensionalidade
    if size(C, 1) != length(oferta) || size(C, 2) != length(demanda)
        error("Dimensionalidade da matriz de custos não é compatível com os vetores de oferta e demanda.")
    end

    rank = size(C, 1)+size(C, 2) -1

    for i in 1:rank
        # Criar a matrix da base inicial
        base = zeros(T, rank)

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


    

end

function sort_base(C::Matrix{T},base::Vector{T}) where T
    sort!(base)



end

# criando a mtrix de restrições e tirando a ultima linha para o rank ser igual a m+n - 1 
function create_constraints_matrix(length_oferta, length_demanda)
    A = zeros(Rational, length_oferta + length_demanda - 1, length_oferta*length_demanda)

    for i in 1:length_oferta
        for j in j:length_demanda
            A[i,j+(i-1)*length_oferta + 1] = 1
        end
    end

    return A
end