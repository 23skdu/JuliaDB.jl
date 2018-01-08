using RecipesBase

# threshold to plot partitions rather than data
const PTHRESH = 10_000

#-----------------------------------------------------------------# table and selection
@recipe function f(t::AbstractIndexedTable, selection::Union{Symbol, Number, Pair}; 
                   partition = length(t) > PTHRESH, nparts = 50, reducer = nothing)
    if partition
        o = (reducer == nothing) ? 
            make_reducer(fieldtype(eltype(t), IndexedTables.colindex(t, selection))) : 
            reducer
        @series begin 
            title --> selection 
            reduce(Partition(o, nparts), t; select = selection)
        end
    else
        @series begin 
            title --> selection
            collect(select(t, selection))
        end
    end
end


# Default OnlineStat based on data type
make_reducer(::Type{<:Number}) = Mean()
make_reducer(::Type{T})  where {T<:Union{AbstractString, Symbol}} = CountMap(T)

make_reducer(T) = error("No predefined reducer for $T")