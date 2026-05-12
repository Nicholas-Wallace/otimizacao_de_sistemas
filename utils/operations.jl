export norm!, pivot!

function norm!(M::Matrix{T}, i::Int, j::Int) where T
    @views M[i, :] ./= M[i, j]
end

function pivot!(M::AbstractMatrix{T}, i::Int, j::Int) where T
    norm!(M, i, j)

    operations = Dict{Int,String}()
    @views for r in axes(M, 1)

        if r == i || M[r, j] == 0
            continue
        end
        M[r, j] > 0 ? operations[r] =  "L$r - $(M[r, j])*L$i)" : operations[r] =  "L$r + $(M[r, j])*L$i)"
        M[r, :] .-= M[i, :] .* M[r, j]
        r += 1
    end
    repl_matrix_with_comment(M, comments=operations) |> println
end
