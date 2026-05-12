export print_table, print_rational

function print_table(M::Matrix{T}, variables::Vector{String}, base::Vector{String}) where T
    
    println("| base | ", join(variables, " | "), " | b ", "|")
    for row_m in eachrow(M)
        line = string("|------| ", join(print_rational.(row_m), " | "), "|")
        println(line)
    end
end

function print_pivot(M::Matrix{T}, variables::Vector{String}, base::Vector{String}, i::Int, operation::String) where T
    println("| base | ", join(variables, " | "), " | b ", "|")

    for index in axes(M, 1)
        line = string("|------| ", join(print_rational.(M[index, :]), " | "), "|")
        if i == index
            line *= " <-- ($operation)"
        end
        println(line)
    end

end

function print_rational(n)
    
    if denominator(n) == 1
        return string(numerator(n))
    else
        return string(numerator(n), "/", denominator(n))
    end
end