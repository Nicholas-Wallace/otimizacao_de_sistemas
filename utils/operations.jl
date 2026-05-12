export norm!, pivot!

function norm!(M::Matrix{T}, i::Int, j::Int) where T
    @views M[i, :] ./= M[i, j]
end

function pivot!(M::AbstractMatrix{T}, i::Int, j::Int, variables::Vector{String}, base::Vector{String}) where T
    println("| base | ", join(variables, " | "), " | b ", "|")
    @views for r in axes(M, 1)
        if r == i 
            line = string("|------| ", join(print_rational.(M[i, :]), " | "), "| <--- (pivot)")

        else
            M[r, :] .-= M[i, :] .* M[r, j]
            line = string("|------| ", join(print_rational.(M[r, :]), " | "), "|")
            r += 1
        end


    end
    return M
end
