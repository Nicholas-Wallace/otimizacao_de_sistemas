export norm!, pivot!, is_pivoted

function norm!(M::Matrix{T}, i::Int, j::Int) where T
    if M[i, j] == 0
        error("Pivot element is zero. Cannot normalize.")
    end
    @views M[i, :] ./= M[i, j]
end

function pivot!(M::AbstractMatrix{T}, i::Int, j::Int) where T
    norm!(M, i, j)
    operations = Dict{Int,String}()

    if is_pivoted(M[:, j], i)
        repl_matrix_with_comment(M, comments=operations) |> println
        return
    end
    @views for r in axes(M, 1)
        if r == i || M[r, j] == 0
            continue
        end
        M[r, j] > 0 ? operations[r] =  "L$r - $(M[r, j])*L$i)" : operations[r] =  "L$r + $(M[r, j])*L$i)"
        M[r, :] .-= M[i, :] .* M[r, j]
        r += 1
    end
    repl_matrix_with_comment(M, comments=operations) |> println
    return
end

function is_pivoted(col, j)
    return col[j] == 1 && sum(col) == 1
end