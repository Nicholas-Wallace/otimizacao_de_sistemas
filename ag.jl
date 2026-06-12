using Random
using Statistics 

function ag(pop_size::Int)
    
    # gerar população incial
    population = generate_population(pop_size)

    aptidoes = get_aptidao.(population) # calcular a aptidão de cada indivíduo da população e guarda em um vetor
    population_std = std(aptidoes)


    # seleção 
    torneio!(population, aptidoes)

    # crossover
    crossover!(population)

    # mutação
    mutacao!(population)
end

function population_std(population::Vector{Tuple{BitVector, BitVector}})
    population_mean = get_aptidao.(population)
end

function generate_population(pop_size::Int)
    # vamos gerar a população inicial respeitando a restrição x^2 + y^2 = 1
    population = Vector{Tuple{BitVector, BitVector}}(undef, pop_size)

    for i in 1:pop_size
        x = 2*rand() - 1 # geramos um numero aleatório entre -1 e 1
        y = sqrt(1 - x^2) # y já está amarrado pela restrição
        population[i] = (generate_bitvector(x), generate_bitvector(y)) # adicionamos a tupla de bitvectors à população
    end

    return population
end

function generate_bitvector(x::Float64)
    
    x = Float16(x)
    u = reinterpret(UInt16, x) # view as a unsigned Int
    s = bitstring(u)
    bv = BitVector([c =='1' for c in s])
    return bv

end

function get_float_back(bv::BitVector)
    u::UInt16 = 0
    for bit in bv                          # assume MSB-first
        u = (u << 1) | (bit ? UInt16(1) : UInt16(0))
    end
    y = Float32(reinterpret(Float16, u))
    return y
end

function get_aptidao(indv::Vector{BitVector}; max=true)
    
    indv_x = get_float_back(indv[1])
    indv_y = get_float_back(indv[2])

    if max
        return (indv_x - 1)^2 + indv_y^2 -2
    else
        return -(indv_x - 1)^2 + indv_y^2 -2
    end
end

function roleta!(population::Vector{Tuple{BitVector, BitVector}}, aptidoes::Vector{Float16})
    
    aptos = Set()

    for i in 1:length(population)/2
        idx = rand(Categorical(aptidoes))
        push!(aptos, idx)
    end

    return aptos

end

function torneio!(population::Vector{Tuple{BitVector, BitVector}}, aptidoes::Vector{Float16})
    aptos = Vector{Tuple{BitVector, BitVector}}(undef, div(length(population), 2))
              
    # cria um conjunto com todos os indices
    idx = Set(1:length(population))

    for i in eachindex(aptos)
        
        indv1 = pop!(idx, rand(idx)) # sorteia um dos indices e o remove do conjunto
        indv2 = pop!(idx, rand(idx))
    
        if aptidoes[indv1] > aptidoes[indv2]
            aptos[i] = population[indv1]

        else
            aptos[i] = population[indv2]
        end

    end

    resize!(population, length(aptos)) # nova população agora são os aptos
    copyto!(population, aptos)

end