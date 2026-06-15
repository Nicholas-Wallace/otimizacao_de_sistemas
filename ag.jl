using Random
using Statistics 

function ag(pop_size::Int, geracoes::Int)
    
    # gerar população incial
    population = generate_population(pop_size)
    
    aptidoes = [get_aptidao(population[:, i]) for i in 1:size(population,2)]
    println("media inicial: ", mean(aptidoes))

    for i in 1:(geracoes-1)
	    # seleção 
	    population = torneio(population, aptidoes)

	    # crossover
	    population = crossover(population)

	    # mutação
	    
 	    mutacao.(population)
    		    
	    aptidoes = [get_aptidao(population[:, i]) for i in 1:size(population,2)]
            println("media iteracao $i: ", mean(aptidoes))
    
    end

end

function population_std(population::Vector{Tuple{BitVector, BitVector}})
	z = [f(get_float_back(indv[1]), get_float_back(indv[2])) for indv in eachcol(population)]
	return std(z)
end

function mean_population(population::Matrix{BitVector})
	z = [f(get_float_back(indv[1]), get_float_back(indv[2])) for indv in eachcol(population)]
	return mean(z)
end

function f(x, y)
	return (x - 1)^2 + y^2 - 2
end

function generate_population(pop_size::Int)
    population = Matrix{BitVector}(undef, 2, pop_size) # a população é uma matrix de BitVectors onde cada coluna é um individo e cada linha uma cordenada
    for i in eachindex(population)
        population[i] = bitrand(22)     # geramos um bitvector aleatorio para cada individuo
    end
    return population
end

function crossover_indv(indv1::BitVector, indv2::BitVector)
    if length(indv1) != length(indv2)
        error("Tamanho dos individuos nao bate")
    end

    n = length(indv1)
    pivot = rand(1:n)
    
    filhos = Matrix{BitVector}(undef, 1, 2)

    if pivot == 1
    	filhos[1] = BitVector(vcat(indv1[1], indv2[2:end]))
    	filhos[2] = BitVector(vcat(indv2[1], indv1[2:end]))
   
    elseif pivot == n
    	filhos[1] = BitVector(vcat(indv1[1:end-1], indv2[end]))
    	filhos[2] = BitVector(vcat(indv2[1:end-1], indv1[end]))
    
    else
        filhos[1] = BitVector(vcat(indv1[1:pivot], indv2[pivot+1:end]))
        filhos[2] = BitVector(vcat(indv2[1:pivot], indv1[pivot+1:end]))
          
    end
    
    println("pai 1: ", indv1)
    println("pai 2: ", indv2)
    println("---------------", pivot,"---------------")
    println("filho 1: ", filhos[1])
    println("filho 2: ", filhos[2])
    
    return filhos

end

function crossover_indv(indv1::Matrix{BitVector}, indv2::Matrix{BitVector})
    if length(indv1) != length(indv2)
        error("Tamanho dos individuos nao bate")
    end

    n = length(indv1)
    pivot = rand(1:n)
    
    filhos = Matrix{BitVector}(undef, 1, 2)

    if pivot == 1
    	filhos[1] = BitVector(vcat(indv1[1], indv2[2:end]))
    	filhos[2] = BitVector(vcat(indv2[1], indv1[2:end]))
   
    elseif pivot == n
    	filhos[1] = BitVector(vcat(indv1[1:end-1], indv2[end]))
    	filhos[2] = BitVector(vcat(indv2[1:end-1], indv1[end]))
    
    else
        filhos[1] = BitVector(vcat(indv1[1:pivot], indv2[pivot+1:end]))
        filhos[2] = BitVector(vcat(indv2[1:pivot], indv1[pivot+1:end]))
          
    end
    
    println("pai 1: ", indv1)
    println("pai 2: ", indv2)
    println("---------------", pivot,"---------------")
    println("filho 1: ", filhos[1])
    println("filho 2: ", filhos[2])
    
    return filhos

end


function crossover(population::Matrix{BitVector}; prob = 0.6)
    # cria um conjunto com todos os indices
    idx = Set(1:size(population, 2))
    
    new_population = population
    for i in 1:size(population, 2)
        @show i
        if @show rand(Float32) <= 0.6 && length(idx) >= 2
        	idx1 = pop!(idx, rand(idx)) # sorteia um dos indices e o remove do conjunto
		idx2 = pop!(idx, rand(idx))              		
		
				
     	   	filho = vcat(crossover_indv(population[1,idx1], population[1,idx2]), crossover_indv(population[2,idx1], population[2,idx2]))
        	new_population = hcat(new_population, filho)
        end
    end
    return new_population
end

function mutacao(dna::BitVector)

	for i in eachindex(dna)
		if rand(Float32) <= 0.01
			@show dna
			dna[i] = !dna[i]
			println("mutacao idx: ", i)
			@show dna
		end	
	end 
	
	return dna

end

function get_float_back(bv::BitVector)
    u::UInt16 = 0
    for bit in bv                          # gera o Int baseado no bitvector
        u = (u << 1) | (bit ? UInt16(1) : UInt16(0))
    end

    min = -3
    max = 3
    n = length(bv)
    x = min+(max-min)*u/(2^n - 1) 

    return x
end

function get_aptidao(indv::Vector{BitVector}; max=true)
    
    indv_x = get_float_back(indv[1])
    indv_y = get_float_back(indv[2])

    # assuminfo qualquer penalidade para restrição r(x, y) = z como p = r(x, y) - z
    penalidade = indv_x^2 + indv_y^2 - 1 
    # adicionando um peso maior para a penalidade
    peso = 4
    
    if max
        return f(indv_x, indv_y) - peso*penalidade
    else
        return -f(indv_x, indv_y) - peso*penalidade
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

function print_indv(indv::Vector{BitVector})
	print("x: ", get_float_back(indv[1]))
	print(" y: ", get_float_back(indv[2]))
	print("\n")
	println("aptidão: ", get_aptidao(indv))
end

function torneio(population::Matrix{BitVector}, aptidoes::Vector{Float64})
    ncols = size(population, 2)
    nrows = size(population, 1)
    m = div(ncols, 2)
    winners = Array{BitVector,2}(undef, nrows, m)

    idx = Set(1:ncols)

    for i in 1:m
        idx1 = pop!(idx, rand(idx))
        idx2 = pop!(idx, rand(idx))

        indv1 = population[:, idx1]
        indv2 = population[:, idx2]
        
        if aptidoes[idx1] > aptidoes[idx2]
            print_indv(indv1)
            winners[:, i] = indv1
        else
            print_indv(indv2)
            winners[:, i] = indv2
        end
    end

    return winners
end
