using Compat.Test

import QuCircuit: Cache, cache, phase

# Block Trait
import QuCircuit: cache_level
import QuCircuit: nqubit, ninput, noutput, isunitary,
                    iscacheable, cache_type, ispure, get_cache
# Required Methods
import QuCircuit: apply!, update!, cache!


@testset "cache" begin

    inner_g = phase(2.0)
    cache_g = cache(inner_g, 3)

    # default cache level is 0
    @test cache_level(cache(inner_g)) == 0
    @test cache_level(cache_g) == 3

    # TODO: check if cache inherit properties from non-unitary, im-cacheable blocks
    for trait in [nqubit, ninput, noutput, isunitary, iscacheable, cache_type, ispure]
        @eval begin
            @test $trait($cache_g) == $trait($inner_g)
        end
    end

    # cache
    @test isempty(get_cache(cache!(cache_g, 2))) == true # will not cache, 3 is great than 2
    @test isempty(get_cache(cache!(cache_g, 6))) == false # will cache

    cache!(cache_g, 6)
    @test length(get_cache(cache_g)) == 1 # will not cache, parameter is not changed
    
    update!(cache_g, 1.0)
    @test inner_g.theta == 1.0 # will change inner block
    cache!(cache_g, 6)
    @test length(get_cache(cache_g)) == 2 # will cache, parameter was updated

    # default is a sparse matrix in CSC
    @test typeof(cache_g.cache[cache_g.block]) <: SparseMatrixCSC

    # allow cache dense matrix
    # this should be faster for small matrix
    # and this will also allow us use StaticArray
    # to accelerate small gates
    dense_cache = cache(inner_g, method=Matrix)
    cache!(dense_cache)
    @test typeof(dense_cache.cache[dense_cache.block]) <: Matrix
end